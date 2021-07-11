# Data Engineering Project - WebScrape Step
# Goals
# 1. - Read books information from a site (https://books.toscrape.com/) - all 50 pages
# 2. - Save to intermediate file
# 3. - Load the intermadiate file
# 4. - Save on Database in order to provide these information to some Data Scientist
# 5. - Schedule this job to run dialy.


# STEP 1 - Read Website Information (https://books.toscrape.com/) all 50 oages
# To accomplish this step, we used a lib called Selenium:
#   1.1 - Install Selenium Library using command like: pip install selenium or conda install selenium
#   1.2 - Selenium requeres a driver to interface with brownser. We used Firefox
#       1.2.2 - download on this link https://github.com/mozilla/geckodriver/releases
#       1.2.3 - Put on Path - Environment Variables (Windows or Linux) the path of this exe file (geckodriver.exe)
# 

# Load Libraries needed
import pandas as pd
from pandas.core.frame import DataFrame
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

# Create 2 empty List to store books information, in this case, complete book name and price
lstBooksNames = []
lstBooksPrices = []

# The robot open the Firefox Brownser
driver = webdriver.Firefox()

# Create a Flag Variable show we can load the site page
LoadNextPage = False

try:
    # Open site https://books.toscrape.com/ on Firefox Brownser
    driver.get("https://books.toscrape.com/")
    # Wait 10 segunds to continue the process 
    driver.implicitly_wait(10)
    # Maximize de Firefox brownser window
    driver.maximize_window()
    #Look for button next on site page
    nextBtn = driver.find_element_by_link_text('next')

    # If found, it is not last page
    if nextBtn is not None:
        LoadNextPage=True

    while LoadNextPage:
        # Load all html selector with name article.product_pod
        # This selecor contais the books list of the page
        books = driver.find_elements_by_css_selector('article.product_pod')

        # If this List is defferent oh nothing, it exists
        if books is not None:
            # For Each Book on the Book List
            for book in books:
                # Get Tag H3 and after a on the html Book List
                BookTag_H3 = book.find_element_by_css_selector("h3")
                BookTag_A = BookTag_H3.find_element_by_css_selector('a')
                # Get title attribute of a tha contains entiry book name
                BookTitle = BookTag_A.get_attribute("title")
                # Add complete name of book to list
                lstBooksNames.append(BookTitle)

                # Get Html Selector of Book Price
                BookPrice = book.find_element_by_css_selector("div.product_price > p")
                strBookPrice = BookPrice.text
                # Remove Libre Current Symbol
                BookPrice = BookPrice.replace("£","")

                # Add price of book to list
                lstBooksPrices.append(BookPrice)

        #Check if next button exists on page
        if len(driver.find_elements_by_link_text('next'))>0:
            # If exists, can load next page
            LoadNextPage = True
            # Get next button object to interate
            nextBtn = driver.find_element_by_link_text('next')
            # Click the next button to load next book list page
            nextBtn.click()
        else:
            # If not exists, it is the last page
            LoadNextPage = False
            break    

       
        
        continue
    
    # Transform lists in list of tuples
    tplsLivros = list(zip(lstBooksNames,lstBooksPrices))
    # Load Tuple into da DataFrame
    dfLivros = pd.DataFrame(tplsLivros,columns=['Book','Price'])
    # Save DataFrame to CSV file to next script save on Postgre Database
    dfLivros.to_csv("C:/DSA/Selenium/SiteBooks2Scrape.csv",index=False)

except:
    #print("The site is out!")
    pass

# Close Firefox Brownser Robot
driver.close()
