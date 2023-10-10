""" Utility functions for GGR337 CKAN API lab.

These functions have been adapted from Data 100 course materials.
"""

def retrieve_package(keys):
    """Downloads package info of a dataset using CKAN's API

    Args:
        keys (dict): A Python dictionary with Twitter authentication
          keys (strings), like this (but filled in):
            {
                "id": "<dataset id here>",
            }

    Returns:
        list: A list of Dictonary objects, each representing one tweet."""
    import requests
    # Toronto Open Data is stored in a CKAN instance. It's APIs are documented here:
    # https://docs.ckan.org/en/latest/api/
    base_url = "https://ckan0.cf.opendata.inter.prod-toronto.ca"
    # Datasets are called "packages". Each package can contain many "resources"
	# To retrieve the metadata for this package and its resources, use the package name in this page's URL:
    url = base_url + "/api/3/action/package_show"
    package = requests.get(url, params = keys).json()
    return package

def load_vader():
    """Returns a DataFrame of the VADER sentiment lexicon. Row indices correspond
    to the word or symbol. The polarity column gives the sentiment associated with
    a given word.
    
    Requires the VADER lexicon to be in the working directory in 'vader_lexicon.txt'."""
    import pandas as pd
    vader = open('vader_lexicon.txt').readlines()
    sent = pd.DataFrame(data=[x.replace('\n', '').split('\t') for x in vader],
                        columns=['sent', 'polarity', 'x', 'y']).drop(columns=['x', 'y'])
    sent.set_index('sent', inplace=True)
    sent['polarity'] = sent['polarity'].apply(float)
    return sent

def clean_string(s):
    """Lowercase and remove punctuation from a pd.Series object containing text.
    
    Args:
        data (pd.Series-like): a series containing text"""
    import re
    result = s.apply(str.lower)
    punct_re = r'[^a-zA-Z0-9\s]'
    result = [re.sub(pattern=punct_re, repl=' ', string=i) for i in result]
    return result

def compose_polarity(df, lex):
    """Compose the polarity for each tweet by summing the polarity value from lex
    for each word in df.
    
    Args:
        df (DataFrame): a single-column collection of responses indexed by respondent ID.
        lex (DataFrame): a sentiment lexicon containing one column "polarity". The row indices
            of this df must be words."""
    tidy_format = df.str.split(expand=True).stack().reset_index()
    tidy_format = tidy_format.set_index('id').rename(columns={'level_1': 'num', 0: 'word'})
    pol = tidy_format.merge(lex, how='left', left_on='word', right_index=True)
    return pol.groupby(pol.index).agg({'polarity': sum})