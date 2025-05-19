import os
import platform
import subprocess
from typing import Any

import yaml
from dotenv import load_dotenv
from invoke import Context, task
from jinja2 import BaseLoader, Environment

from tasks.install.download import PackageDownloader

load_dotenv()


def get_goarch():
    arch = platform.machine().lower()

    # Mapping common platform.machine() outputs to GOARCH values
    arch_map = {
        "x86_64": "amd64",
        "amd64": "amd64",
        "i386": "386",
        "i686": "386",
        "x86": "386",
        "arm64": "arm64",
        "aarch64": "arm64",
        "armv7l": "arm",
        "armv6l": "arm",
        "ppc64le": "ppc64le",
        "ppc64": "ppc64",
        "mips": "mips",
        "mipsle": "mipsle",
        "mips64": "mips64",
        "mips64le": "mips64le",
        "s390x": "s390x",
    }

    goarch = arch_map.get(arch)
    if not goarch:
        raise ValueError(f"Unsupported architecture: {arch}")
    return goarch


def get_rust_arch():
    """
    Returns the system architecture string similar to Rust's arch naming.
    Examples: 'x86_64', 'aarch64', 'arm', 'i386', etc.
    """
    machine = platform.machine().lower()

    # Normalize common architecture names to Rust-like arch strings
    if machine in ("x86_64", "amd64"):
        return "x86_64"
    elif machine in ("i386", "i686", "x86"):
        return "x86"
    elif machine.startswith("armv7") or machine == "arm":
        return "arm"
    elif machine.startswith("aarch64") or machine == "arm64":
        return "aarch64"
    elif machine.startswith("ppc64"):
        return "powerpc64"
    elif machine.startswith("ppc"):
        return "powerpc"
    else:
        return machine  # fallback to whatever platform.machine() returns


OS = subprocess.check_output(["uname", "-s"], text=True).strip().lower()
ARCH = get_goarch()
INSTALL_PATH = os.getenv("INSTALL_PATH", "/usr/local/bin")
ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
METADATA_FILE = os.path.join(os.path.dirname(__file__), "metadata.yaml")

with open(METADATA_FILE) as f:
    METADATA = yaml.safe_load(f)


def render_download_url(package_metadata: dict[str, Any]) -> str:
    env = Environment(loader=BaseLoader())
    template = env.from_string(package_metadata["download_url"])
    result = template.render(
        os=OS, arch=ARCH, rust_arch=get_rust_arch(), **package_metadata
    )
    return result


@task(aliases=["p"])
def package(c: Context, name: str, dist: bool = True, force: bool = False) -> None:
    package_metadata = next(
        (package for package in METADATA["packages"] if package["name"] == name),
        None,
    )

    package_name = package_metadata["name"]
    download_url = render_download_url(package_metadata)
    install_path = os.path.join(ROOT_DIR, "dist") if dist else INSTALL_PATH

    if force:
        c.run(f"rm -rvf {install_path}/{package_name}")

    if os.path.exists(os.path.join(install_path, package_name)):
        print(f"{package_name} already installed")
    else:
        downloader = PackageDownloader(
            c,
            package_name=package_name,
            download_url=download_url,
            install_path=install_path,
            package_exe=package_metadata.get("package_exe", None),
            binary=package_metadata.get("binary", False),
        )

        downloader.download()


@task(aliases=["a", "all"])
def all_packages(c: Context, dist: bool = True, force: bool = False) -> None:
    for package_name in (package["name"] for package in METADATA["packages"]):
        package(c, name=package_name, dist=dist, force=force)
