import os
import subprocess

from dotenv import load_dotenv
from invoke import Context, task

load_dotenv()


DESTINATION_REGISTRY = os.getenv("DESTINATION_REGISTRY", "localhost")
COMMIT_SHA = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"]).strip()


@task
def build(c: Context) -> None:
    c.run(f"podman build . -t localhost/packages:{COMMIT_SHA}")


@task
def tag(c: Context) -> None:
    c.run(f"podman tag localhost/packages:{COMMIT_SHA} localhost/packages:latest")
    c.run(
        f"podman tag localhost/packages:{COMMIT_SHA} {DESTINATION_REGISTRY}/packages:latest"
    )


@task
def push(c: Context) -> None:
    c.run(f"podman push {DESTINATION_REGISTRY}/packages:latest")
