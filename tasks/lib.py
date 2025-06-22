from pathlib import Path
import platform
import subprocess
from typing import Any

from jinja2 import BaseLoader, Environment
import yaml


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


def get_package_metadata(path: str) -> Any:
    with Path.open(METADATA_FILE) as f:
        return yaml.safe_load(f)


OS = subprocess.check_output(["uname", "-s"], text=True).strip().lower()
ARCH = get_goarch()
RUST_ARCH = get_rust_arch()
ROOT_DIR = Path(Path(__file__).parent / Path("..")).resolve()

METADATA_FILE = Path(Path(__file__).parent / Path("metadata.yaml")).absolute()
METADATA = get_package_metadata(METADATA_FILE)


def render_template(package_id: str, package_metadata: dict[str, Any], template_str: str) -> str:
    env = Environment(loader=BaseLoader())
    template = env.from_string(template_str)
    result = template.render(
        os=OS, arch=ARCH, rust_arch=RUST_ARCH, name=package_id, **package_metadata
    )
    return result
