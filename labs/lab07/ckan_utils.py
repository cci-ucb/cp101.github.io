""" Utility functions for GGR337 CKAN API lab.

These functions have been adapted from Data 100 course materials.
"""

def retrieve_package(keys):
    """Downloads package info of a dataset using CKAN's API

    Args:
        keys (dict): A Python dictionary with Toronto Open Dataset id 
          keys (strings), like this (but filled in):
            {
                "id": "<dataset id here>",
            }

    Returns:
        list: A list of Dictonary objects, each representing help, response, and result."""
    import requests
    # Toronto Open Data is stored in a CKAN instance. It's APIs are documented here:
    # https://docs.ckan.org/en/latest/api/
    base_url = "https://ckan0.cf.opendata.inter.prod-toronto.ca"
    # Datasets are called "packages". Each package can contain many "resources"
    # To retrieve the metadata for this package and its resources, use the package name in this page's URL:
    url = base_url + "/api/3/action/package_show"
    package = requests.get(url, params = keys).json()
    return package


def load_tpl_events(method):
     """Loads the dataframe of the toronto public library events feeding using the predownloaded csv or API request
    
    Args:
        method (string): can either be 'read_csv' for predownloaded csv or 'API' for API request
        """
        
    if method == "read_csv":
        return pd.read_csv("tpl-events-feed.csv")
    elif method == "API":
        
        package = retrieve_package("library-branch-programs-and-events-feed")
        
        
        for idx, resource in enumerate(package["result"]["resources"]):
            if resource["datastore_active"]:
                # to get all records in CSV format
                url = base_url + "/datastore/dump/" + resource["id"]
                # do a GET request on the url and access its text attribute
                resource_dump_data = requests.get(url).text
                # read the raw csv text into a pandas dataframe to work with it
                return pd.read_csv(StringIO(resource_dump_data), sep=",")
    else:
        print("Unacceptable argument for 'method'. Use either 'read_csv' or 'API'."
        return

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