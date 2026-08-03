import hashlib
import io
import os
import re
import sys

try:
    import detools
except ImportError:
    print("detools not installed. Run: pip install detools")
    sys.exit(1)

REPO_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

VERSION_FILE = "esp32s3_version_info.txt"
FIRMWARE_FILE = "firmwares3.bin"
ARCHIVE_DIR = "releases"
PATCH_DIR = "patch"

ESP_DELTA_OTA_MAGIC = 0xFCCDDE10
MAGIC_SIZE = 4
DIGEST_SIZE = 32
HEADER_SIZE = 64


def published_version():
    with open(os.path.join(REPO_DIR, VERSION_FILE), "r", encoding="utf-8") as f:
        match = re.search(r"APP_VERSION\D*([0-9.]+)", f.read())

    if match is None:
        raise ValueError("APP_VERSION not found in %s" % VERSION_FILE)

    return match.group(1)


def image_digest(binPath):
    with open(binPath, "rb") as f:
        data = f.read()

    if len(data) <= DIGEST_SIZE:
        raise ValueError("%s is too small to be an app image" % binPath)

    digest = data[-DIGEST_SIZE:]
    if hashlib.sha256(data[:-DIGEST_SIZE]).digest() != digest:
        raise ValueError("%s has no appended SHA-256 image digest" % binPath)

    return digest


def create_patch(basePath, newPath, outPath):
    digest = image_digest(basePath)
    image_digest(newPath)

    body = io.BytesIO()
    with open(basePath, "rb") as base, open(newPath, "rb") as new:
        detools.create_patch(base, new, body, compression="heatshrink")

    patch = body.getvalue()
    os.makedirs(os.path.dirname(outPath), exist_ok=True)

    with open(outPath, "wb") as out:
        out.write(ESP_DELTA_OTA_MAGIC.to_bytes(MAGIC_SIZE, "little"))
        out.write(digest)
        out.write(bytes(HEADER_SIZE - MAGIC_SIZE - DIGEST_SIZE))
        out.write(patch)

    return patch


def verify_patch(basePath, newPath, patch):
    rebuilt = io.BytesIO()
    with open(basePath, "rb") as base:
        detools.apply_patch(base, io.BytesIO(patch), rebuilt)

    with open(newPath, "rb") as new:
        expected = new.read()

    if rebuilt.getvalue() != expected:
        raise ValueError("patch does not reproduce %s" % newPath)


def base_versions(version):
    archiveRoot = os.path.join(REPO_DIR, ARCHIVE_DIR)
    if not os.path.isdir(archiveRoot):
        return []

    bases = []
    for name in sorted(os.listdir(archiveRoot)):
        if name == version:
            continue
        basePath = os.path.join(archiveRoot, name, FIRMWARE_FILE)
        if os.path.isfile(basePath):
            bases.append((name, basePath))

    return bases


def main():
    version = published_version()
    newBin = os.path.join(REPO_DIR, FIRMWARE_FILE)

    if not os.path.isfile(newBin):
        print("%s missing" % FIRMWARE_FILE)
        return 1

    archivedBin = os.path.join(REPO_DIR, ARCHIVE_DIR, version, FIRMWARE_FILE)
    if os.path.isfile(archivedBin):
        if open(archivedBin, "rb").read() != open(newBin, "rb").read():
            print("%s differs from %s/%s/%s - inconsistent release"
                  % (FIRMWARE_FILE, ARCHIVE_DIR, version, FIRMWARE_FILE))
            return 1
    else:
        print("WARNING: v%s is not archived under %s/, patches to it stay possible "
              "only while %s is untouched" % (version, ARCHIVE_DIR, FIRMWARE_FILE))

    bases = base_versions(version)
    if not bases:
        print("no base versions archived, nothing to do")
        return 0

    print("published version : %s" % version)
    print("new image sha256  : %s" % image_digest(newBin).hex())

    failed = 0
    for baseVersion, basePath in bases:
        outPath = os.path.join(REPO_DIR, PATCH_DIR,
                               "firmwares3_%s_to_%s.patch" % (baseVersion, version))
        if os.path.isfile(outPath):
            print("  %s -> %s : already present" % (baseVersion, version))
            continue

        try:
            patch = create_patch(basePath, newBin, outPath)
            verify_patch(basePath, newBin, patch)
        except Exception as error:
            print("  %s -> %s : FAILED (%s)" % (baseVersion, version, error))
            failed += 1
            continue

        patchSize = os.path.getsize(outPath)
        print("  %s -> %s : %d bytes (%.1f%% of full image)"
              % (baseVersion, version, patchSize,
                 100.0 * patchSize / os.path.getsize(newBin)))

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
