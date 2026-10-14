import os, requests

key = os.environ["VERSION_HISTORY"]
url = "https://assetdelivery.roblox.com/v2/assetId/123600574843310/version/1"

response = requests.get(url, headers={"x-api-key": key})

print(response.status_code)
print(response.text)
