import os
from pathlib import Path

from dotenv import load_dotenv
from invoke import Context, task

from tasks.install.download import PackageDownloader
from tasks.lib import METADATA, ROOT_DIR, render_template

load_dotenv()


INSTALL_PATH = os.getenv("INSTALL_PATH", "/usr/local/bin")


@task(aliases=["p"])
def package(c: Context, name: str, dist: bool = True, force: bool = False) -> None:
    package_metadata = METADATA[name]

    download_url = render_template(name, package_metadata, package_metadata["download_url"])
    install_path = Path(Path(ROOT_DIR) / Path("dist")).absolute() if dist else INSTALL_PATH

    if force:
        c.run(f"rm -rvf {install_path}/{name}")

    if Path(Path(install_path) / Path(name)).exists():
        print(f"{name} already installed")
    else:
        downloader = PackageDownloader(
            c,
            package_name=name,
            download_url=download_url,
            install_path=install_path,
            package_exe=package_metadata.get("package_exe", None),
            binary=package_metadata.get("binary", False),
        )

        downloader.download()


@task(aliases=["a", "all"])
def all_packages(c: Context, dist: bool = True, force: bool = False) -> None:
    for package_id in METADATA:
        package(c, name=package_id, dist=dist, force=force)
