import requests
from bs4 import BeautifulSoup
import re

### Get the latest dorado download link ###
### If an error occurs, this script does not prints anything ###

# URL of the webpage you want to scrape
url = 'https://dorado-docs.readthedocs.io/en/latest/'

# Fetch the webpage
response = requests.get(url)
response.raise_for_status()  # Raise an error for bad responses

soup = BeautifulSoup(response.content, 'html.parser')

# Extract text from the webpage
text = soup.get_text()

# Find the link for linux x64
pattern = r'https://cdn\.oxfordnanoportal\.com/software/analysis/dorado-(\d+(?:\.\d+)*-linux-x64\.tar\.gz)'

# Search for the pattern in the extracted text
match = re.search(pattern, text)

if match:
    link = match.group()  # Extract the link
    print(link)
