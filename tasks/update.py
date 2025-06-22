from pathlib import Path
import re
from urllib.parse import urlparse

from invoke import Context, task
import requests
import semver
import yaml

from tasks.lib import METADATA, METADATA_FILE


def get_owner_and_repo(url: str):
    """
    Extracts the owner and repository name from a GitHub URL.

    Supports:
    - https://github.com/owner/repo
    - https://github.com/owner/repo.git
    - git@github.com:owner/repo.git

    Returns:
        (owner, repo) tuple, or (None, None) if not recognized.
    """
    if url.startswith("git@"):
        # SSH URL: git@github.com:owner/repo.git
        try:
            path = url.split(":", 1)[1]
            if path.endswith(".git"):
                path = path[:-4]
            owner, repo = path.split("/", 1)
            return owner, repo
        except Exception:
            return None, None
    else:
        # HTTPS or HTTP URL
        try:
            parsed = urlparse(url)
            path = parsed.path
            if path.startswith("/"):
                path = path[1:]
            if path.endswith(".git"):
                path = path[:-4]
            owner, repo = path.split("/", 1)
            return owner, repo
        except Exception:
            return None, None


def get_latest_github_release_version(owner: str, repo: str) -> str:
    """
    Get the version tag of the latest release from a GitHub repository.

    Parameters:
        owner (str): GitHub username or organization name owning the repo.
        repo (str): Repository name.

    Returns:
        str: The tag name of the latest release, e.g. 'v1.0.0'.
             Returns None if the release is not found or request fails.
    """
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    headers = {"Accept": "application/vnd.github+json", "X-GitHub-Api-Version": "2022-11-28"}
    try:
        response = requests.get(url, headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            return data.get("tag_name")
        else:
            print(f"Failed to get latest release: HTTP {response.status_code}")
    except requests.RequestException as e:
        print(f"Error fetching latest release: {e}")
    return None


@task(aliases=["p"])
def package(c: Context, name: str) -> None:
    package_metadata = METADATA[name]

    current_semver = package_metadata["version"]
    print(f"{name}: current version: {current_semver}")
    repo_owner, repo_name = get_owner_and_repo(package_metadata["repo_url"])
    latest_tag = get_latest_github_release_version(repo_owner, repo_name)
    match = re.search(r"v?(\d+\.\d+\.\d+)", latest_tag)

    if match:
        latest_semver = match.group(0)
        latest_semver = latest_semver.lstrip("v")
    else:
        print("No version found.")

    print(f"{name}: latest version: {latest_semver}")

    if semver.compare(current_semver, latest_semver) == -1:
        print(f"{name}: upgrading to version {latest_semver}")
        package_metadata["version"] = latest_semver
        METADATA[name] = package_metadata

        with Path.open(METADATA_FILE, "w") as f:
            f.write(yaml.dump(METADATA))


@task(aliases=["a", "all"])
def all_packages(c: Context) -> None:
    for package_name in METADATA:
        package(c, name=package_name)
