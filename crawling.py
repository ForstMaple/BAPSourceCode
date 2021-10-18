#!/usr/bin/env python
# -*- coding: UTF-8 -*-

'''
@Author  ：Maple FENG
@Date    ：2021-10-18
'''

import asyncio
import aiohttp
from html import unescape
from bs4 import BeautifulSoup
import pandas as pd
from langdetect import detect

# Defining a header for GET method
headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36'}

# Reading the file
courses = pd.read_csv('coursera_courses_catalog.csv')

# Filtering out projects
courses = courses.loc[courses['course_type'] != 'GUIDED PROJECT']
courses = courses.loc[courses['university_name'] != 'Coursera Project Network']
# language = courses['course_name'].apply(lambda x: detect(x))
# courses = courses[language == 'en']

# Filtering out non-English course
courses = courses[courses['course_language'] == 'English']

# Resetting thte index
courses.reset_index(drop=True, inplace=True)

# Gettign the course links
links = courses['course_link']
results = []

# Setting the max semaphore to avoid too many sessions at the same time
sem = asyncio.Semaphore(10)

async def get_info(link):
    with(await sem):
        async with aiohttp.ClientSession() as session:
            async with session.request('GET', link, headers=headers) as resp:
                text = await resp.text()
                # Using BeautifulSoup for parsing the webpage
                soup = BeautifulSoup(text, 'lxml')
                # Setting default values to signify errors if any
                title = provider = course_description = num_subscriber = 'na'
                try:
                    # Locating and Extracting the information
                    title = unescape(soup.find(class_='banner-title banner-title-without--subtitle m-b-0').string.strip())
                    provider = unescape(soup.find(class_='headline-4-text bold rc-Partner__title').string.strip())
                    course_description = unescape(soup.find(class_='content-inner').p.string.strip())
                    num_subscriber = unescape(soup.find(class_='_1fpiay2').find_all('span')[1].string.strip())
                except:
                    pass
                # print(title)
                # print(provider)
                # print(num_subscriber)
                # print(course_description[:20])
                # print('\n')
                return link, title, provider, num_subscriber, course_description

# For calling the above function
def main():
    loop = asyncio.get_event_loop()
    tasks = [get_info(link) for link in links]
    results = loop.run_until_complete(asyncio.wait(tasks))
    loop.close()
    result = [result.result() for result in results[0]]
    result_df = pd.DataFrame(result, columns=['link', 'title', 'provider', 'n_subscribers', 'description'])
    result_df.to_csv('result.csv')

if __name__ == '__main__':
    main() 

