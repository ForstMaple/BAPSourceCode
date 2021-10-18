#!/usr/bin/env python
# -*- coding: UTF-8 -*-

'''
@Author  ：Maple FENG
@Date    ：2021-10-18

This is the following step of crawling.py, which joins the crawling result with the origin dataset.
'''

import pandas as pd

# Reading the files
courses = pd.read_csv('coursera_courses.csv')
other = pd.read_csv('result.csv')

# Filtering out projects and non-English courses
courses = courses.loc[courses['course_type'] != 'GUIDED PROJECT']
courses = courses.loc[courses['university_name'] != 'Coursera Project Network']
courses = courses[courses['course_language'] == 'English']
courses.reset_index(drop=True, inplace=True)

# Joining the two DataFrames
new_df = courses.join(other.set_index('link'), on='link', how='inner')

# Exporting as a csv file
new_df.to_csv('new.csv', index=False)
