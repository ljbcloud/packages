import json
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
    """
    url = f"https://api.github.com/repos/{owner}/{repo}/releases/latest"
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
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


def update_package(c: Context, name: str):
    """
    Try updating a single package.
    Returns:
        dict: {
            "package": str,
            "updated": bool,
            "from_version": str or None,
            "to_version": str or None
        }
    """
    package_metadata = METADATA[name]
    current_semver = package_metadata["version"]

    repo_owner, repo_name = get_owner_and_repo(package_metadata["repo_url"])
    latest_tag = get_latest_github_release_version(repo_owner, repo_name)

    match = re.search(r"v?(\d+\.\d+\.\d+)", latest_tag or "")
    if not match:
        return {
            "package": name,
            "updated": False,
            "from_version": current_semver,
            "to_version": None,
        }

    latest_semver = match.group(1)  # stripped leading "v"

    if semver.compare(current_semver, latest_semver) == -1:
        package_metadata["version"] = latest_semver
        METADATA[name] = package_metadata

        with Path.open(METADATA_FILE, "w") as f:
            f.write(yaml.dump(METADATA))

        return {
            "package": name,
            "updated": True,
            "from_version": current_semver,
            "to_version": latest_semver,
        }

    return {
        "package": name,
        "updated": False,
        "from_version": current_semver,
        "to_version": current_semver,
    }


@task(aliases=["p"])
def package(c: Context, name: str) -> None:
    """Update a single package and print JSON result."""
    result = update_package(c, name)
    print(json.dumps(result, indent=2))


@task(aliases=["a", "all"])
def all_packages(c: Context) -> None:
    """Update all packages and print JSON results."""
    results = [update_package(c, pkg) for pkg in METADATA]
    if len(results) > 0:
        print(json.dumps([res for res in results if res.get("updated", False)], indent=2))
