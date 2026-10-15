from pathlib import Path
import shutil, subprocess
from versions import versions

template = Path("default.project.json")
downloads = Path("downloads")
snapshots = Path("snapshots")
folders = ["ReplicatedStorage", "ServerScriptService", "StarterGui", "StarterPlayerScripts"]

def convert_version(version: int):
    rbxl = downloads / f"{version}.rbxl"
    snap = snapshots / str(version)

    if not rbxl.exists():
        raise RuntimeError(f"Missing download: {rbxl}")

    for name in folders:
        (snap / "src" / name).mkdir(parents=True, exist_ok=True)

    shutil.copy(template, snap / "default.project.json")

    subprocess.run(
        ["rojo", "syncback", str(snap), "--input", str(rbxl), "--non-interactive"],
        check=True
    )

    return snap

if __name__ == "__main__":
    for entry in versions:
        try:
            path = convert_version(entry["version"])
            print("converted version:", path)
        except Exception as e:
            print("Failed on version", entry["version"], "-", e)