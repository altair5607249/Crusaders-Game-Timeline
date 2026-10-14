#this is for automating the curation of Crusaders's different versions, since scrolling through Roblox's version control is too laggy
#manually navigating through 7000 versions took me over an hour, so i will not be partaking in that again

from pathlib import Path
import os, requests

placeId = "123600574843310"
version = 1 #test

key = os.environ["VERSION_HISTORY"]
url = f"https://apis.roblox.com/asset-delivery-api/v1/assetId/{placeId}/version/{version}"

response = requests.get(url, headers={"x-api-key": key})

if response.status_code != 200:
    raise SystemExit(f"First request failed: {response.status_code}")

link = response.json()["location"]

file_response =  requests.get(link)

if file_response.status_code != 200:
    raise SystemExit(f"Download failed: {file_response.status_code}")

out_dir = Path("downloads")
out_dir.mkdir(exist_ok=True)
out_path = out_dir / f"{version}.rbxl"

with open(out_path, "wb") as f:
    f.write(file_response.content)

print(out_path, out_path.stat().st_size, "bytes")
print(open(out_path, "rb").read(8))