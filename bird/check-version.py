#!/usr/bin/env python3
"""Find the newest stable BIRD 3 package shared by both Wolfi architectures."""

import argparse
import io
import json
import os
from pathlib import Path
import re
import tarfile
from urllib.error import HTTPError
from urllib.parse import quote
from urllib.request import Request, urlopen


VERSION = re.compile(r"3\.\d+\.\d+-r\d+")


def versions(archive):
    # Signed APKINDEX files contain concatenated gzip/tar streams.
    with tarfile.open(fileobj=io.BytesIO(archive), mode="r:gz", ignore_zeros=True) as index:
        data = index.extractfile("APKINDEX").read().decode()
    result = set()
    for record in data.split("\n\n"):
        fields = dict(line.split(":", 1) for line in record.splitlines() if ":" in line)
        version = fields.get("V", "")
        if fields.get("P") == "bird" and VERSION.fullmatch(version):
            result.add(version)
    return result


def latest_version():
    available = []
    for arch in ("x86_64", "aarch64"):
        with urlopen(f"https://packages.wolfi.dev/os/{arch}/APKINDEX.tar.gz", timeout=60) as response:
            available.append(versions(response.read()))
    common = set.intersection(*available)
    if not common:
        raise RuntimeError("No stable BIRD 3 package available for both architectures")
    return max(common, key=lambda version: tuple(map(int, re.findall(r"\d+", version))))


def published(image, version):
    if not image.startswith("ghcr.io/"):
        raise ValueError("Expected a ghcr.io image")
    owner, package = image.removeprefix("ghcr.io/").split("/", 1)
    headers = {"Accept": "application/vnd.github+json", "X-GitHub-Api-Version": "2022-11-28"}
    if os.environ.get("GHCR_TOKEN"):
        headers["Authorization"] = f"Bearer {os.environ['GHCR_TOKEN']}"

    def get(path):
        with urlopen(Request(f"https://api.github.com{path}", headers=headers), timeout=30) as response:
            return json.load(response)

    owner_type = get(f"/users/{quote(owner, safe='')}")["type"]
    namespace = "orgs" if owner_type == "Organization" else "users"
    # The Packages API returns 404 before the first publication. GHCR's token
    # endpoint may instead return 403 for a repository that does not yet exist.
    path = f"/{namespace}/{quote(owner, safe='')}/packages/container/{quote(package, safe='')}/versions"
    page = 1
    while True:
        try:
            releases = get(f"{path}?per_page=100&page={page}")
        except HTTPError as error:
            if error.code == 404:
                return False
            # Authentication failures and outages must not look like new releases.
            raise
        if any(version in release["metadata"]["container"]["tags"] for release in releases):
            return True
        if len(releases) < 100:
            return False
        page += 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--image", help="Check whether this GHCR image already has the version tag")
    parser.add_argument("--force", action="store_true", help="Rebuild even if the version was published")
    args = parser.parse_args()
    version = latest_version()
    build = args.force or not args.image or not published(args.image, version)
    outputs = {
        "version": version,
        "upstream": version.split("-r")[0],
        "build": str(build).lower(),
    }
    for key, value in outputs.items():
        print(f"{key}={value}")
    if os.environ.get("GITHUB_OUTPUT"):
        with open(os.environ["GITHUB_OUTPUT"], "a") as output:
            for key, value in outputs.items():
                output.write(f"{key}={value}\n")
    if build:
        config = Path(__file__).with_name("apko.yaml").read_text()
        config, count = re.subn(r"bird=3\.\d+\.\d+-r\d+", f"bird={version}", config)
        if count != 1:
            raise RuntimeError("Expected exactly one BIRD package pin")
        Path("bird.resolved.yaml").write_text(config)


if __name__ == "__main__":
    main()
