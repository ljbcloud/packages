import os
import subprocess

from dotenv import load_dotenv
from invoke import Context, task

load_dotenv()

DESTINATION_REGISTRY = os.getenv("DESTINATION_REGISTRY", "localhost")
COMMIT_SHA = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], text=True).strip()


@task
def container(c: Context, registry: str = DESTINATION_REGISTRY, tag: str = COMMIT_SHA) -> None:
    c.run(f"podman build . -t {registry}/packages:{tag}")
