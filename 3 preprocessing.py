#!/usr/bin/env python
# -*- coding: UTF-8 -*-

'''
@Author  ：Maple FENG
@Date    ：2021-10-18

This is the following step of join.py, which performs further data cleaning, data extracting, and train-test splitting.

Some processing steps were doen manually and not covered by code, including but not limited to:
1. Checking the results crawled and the original data
2. Deleting redundant columns after checking
3. Creating the "ranking" column
'''

import numpy as np
import pandas as pd

# Reading data
courses = pd.read_csv('interim version 2')

# Extracting estimated hours to complete the course from 'time_required' column
courses['hours_to_complete'] = courses['time_required'].apply(lambda x: x[x.find('.') + 2 : x.find('h') - 1])
# Converting subtitle list into number of subtitles
courses['num_subtitles'] = courses['subtitles'].apply(lambda x: len(x[11:].split(', ')))
# Extracting ratings from the original strings
courses['rating'] = courses['rating'].apply(lambda x: x[:3] if isinstance(x, str) else np.nan)
# Filling NA values in the level columns with 'Unknown Level'
courses['level'].fillna('Unknown Level', inplace=True)

# Dropping redundant columns
cleaned_df = courses.drop(columns=['time_required', 'subtitles', 'skill', 'rating'])

# Adding a 'log_subscribers' column
cleaned_df['log_subscribers'] = np.log(cleaned_df['subscribers'])

# Exporting the entire processed dataset 
cleaned_df.to_csv('cleaned.csv', index=False)

# Splitting training and testing sets
train = cleaned_df.sample(frac=0.7, random_state=42)
test = cleaned_df.drop(train.index)

# Exporting training and testing sets as csv files
train.to_csv('train1018.csv', index=False)
test.to_csv('test1018.csv', index=False)
