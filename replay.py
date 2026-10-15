from pathlib import Path
import shutil, subprocess
from versions import versions

repo_src = Path("src")
snapshots = Path("snapshots")

def git(*args):
    print("git", *args)
    subprocess.run(["git", *args], check=True)

def wipe_src():
    repo_src.mkdir(exist_ok=True)

    for item in repo_src.iterdir():
        if item.name == "README.md":
            continue
        elif item.is_dir():
            shutil.rmtree(item)
        else:
            item.unlink()

def replay():
    for i, entry in enumerate(sorted(versions, key=lambda e: e["version"]), start=1):
        v = entry["version"]
        snap_src = snapshots / str(v) / "src"
        tag = f"v{i:02d}"
        msg = entry["message"][0].upper() + entry["message"][1:] + f" (Roblox version {v})"

        if not snap_src.exists():
            raise RuntimeError(f"Missing snapshot: {snap_src}")

        wipe_src()
        shutil.copytree(snap_src, repo_src, dirs_exist_ok=True)

        git("add", "src")
        git("commit", "-m", msg)
        git("tag", tag)

if __name__ == "__main__":
    replay()