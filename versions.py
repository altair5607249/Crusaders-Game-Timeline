#this is for automating the curation of Crusaders's different versions, since scrolling through Roblox's version control is too laggy
#manually navigating through 7000 versions took me over an hour, so i will not be partaking in that again

import os, requests

key = os.environ["VERSION_HISTORY"]
url = "https://assetdelivery.roblox.com/v2/assetId/123600574843310/version/1"

response = requests.get(url, headers={"x-api-key": key})

print(response.status_code)
print(response.text)
