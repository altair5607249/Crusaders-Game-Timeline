#this is for automating the curation of Crusaders's different versions, since scrolling through Roblox's version control is too laggy
#manually navigating through 7000 versions took me over an hour, so i will not be partaking in that again

from pathlib import Path
import os, requests, time

placeId = "123600574843310"
key = os.environ["VERSION_HISTORY"]
out_dir = Path("downloads")
out_dir.mkdir(exist_ok=True)

versions = [
    {"version": 100, "message": "character selection, damage, m1, and sprinting"},
    {"version": 580, "message": "knockback and dashing"},
    {"version": 675, "message": "IAS (input action system)/energy"},
    {"version": 900, "message": "cubic hurtboxes and stun"},
    {"version": 1650, "message": "cooldown, mouselock, and UniversalModules (aka space and time)"},
    {"version": 1875, "message": "CMS (character management system)/matter + removed UnmanagedManagers"},
    {"version": 2200, "message": "first bare-style moveset finished (Redd) and movement anticheat"},
    {"version": 2800, "message": "all bare-style movesets finished and animation handler"},
    {"version": 3750, "message": "player data and map management"},
    {"version": 4500, "message": "administration system and mobile support"},
    {"version": 5000, "message": "weapon system"},
    {"version": 5750, "message": "all weapon-style movesets finished"},
    {"version": 6750, "message": ""},
]

def download_version(version: int):
    out_path = out_dir / f"{version}.rbxl"
    if out_path.exists():
        return out_path

    url = f"https://apis.roblox.com/asset-delivery-api/v1/assetId/{placeId}/version/{version}"
    response = requests.get(url, headers={"x-api-key": key}, timeout=10)

    if response.status_code != 200:
        raise RuntimeError(f"First request failed: {response.status_code}")

    link = response.json()["location"]

    file_response =  requests.get(link, timeout=60)

    if file_response.status_code != 200:
        raise RuntimeError(f"Download failed: {file_response.status_code}")

    with open(out_path, "wb") as f:
        f.write(file_response.content)

    return out_path

for entry in versions:
    try:
        path = download_version(entry["version"])
        print("saved:", path)
    except Exception as e:
        print("Failed on version", entry["version"], "-", e)
    time.sleep(1)