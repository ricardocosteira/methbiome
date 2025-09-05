import requests
from bs4 import BeautifulSoup

### Get the latest kraken2 standard database download link ###
### If an error occurs, this script does not prints anything ###

# URL of the webpage to scrape
url = 'https://benlangmead.github.io/aws-indexes/k2'

# Fetch the webpage
response = requests.get(url)
response.raise_for_status()  # Raise an error for bad responses

soup = BeautifulSoup(response.content, 'html.parser')

# Find the <h3> element containing "Latest"
latest_header = soup.find('h3', string=lambda text: text and "Latest" in text)

if latest_header:
    # Find the next table after the <h3> element
    next_table = latest_header.find_next('table')
    
    if next_table:
        # Iterate through the rows of the found table
        for row in next_table.find_all('tr'):
            # Get all the cells in the row
            cells = row.find_all('td')
            if cells and cells[0].text.strip() == "Standard":
                # Extract the link for the standard database
                standard_link = cells[5].find('a')['href']
                break
            
    # Print the latest link for the Standard database if set
    if standard_link:
        print(standard_link)
