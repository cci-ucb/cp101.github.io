""" Utility functions for GGR337 CKAN API lab.

These functions have been adapted from Data 100 course materials.
"""

def download_recent_tweets_by_user(user_account_name, keys):
    """Downloads tweets by one Twitter user.

    Args:
        user_account_name (str): The name of the Twitter account
          whose tweets will be downloaded.
        keys (dict): A Python dictionary with Twitter authentication
          keys (strings), like this (but filled in):
            {
                "consumer_key": "<your Consumer Key here>",
                "consumer_secret":  "<your Consumer Secret here>",
                "access_token": "<your Access Token here>",
                "access_token_secret": "<your Access Token Secret here>"
            }

    Returns:
        list: A list of Dictonary objects, each representing one tweet."""
    import tweepy
    try:
        auth = tweepy.OAuthHandler(keys["consumer_key"], keys["consumer_secret"])
        auth.set_access_token(keys["access_token"], keys["access_token_secret"])
        api = tweepy.API(auth)
        tweets = [t._json for t in tweepy.Cursor(api.user_timeline, id=user_account_name, 
                                             tweet_mode='extended').items()]
    except TweepError as e:
        logging.warning("There was a Tweepy error. Double check your API keys and try again.")
        logging.warning(e)
    return tweets

def download_recent_tweets_by_hashtag(hashtag, keys, location=None, count=15):
    """Downloads tweets associated with a hashtag.

    Args:
        user_account_name (str): The value of the topic associated with out the hashtag
        keys (dict): A Python dictionary with Twitter authentication
          keys (strings), like this (but filled in):
            {
                "consumer_key": "<your Consumer Key here>",
                "consumer_secret":  "<your Consumer Secret here>",
                "access_token": "<your Access Token here>",
                "access_token_secret": "<your Access Token Secret here>"
            }
        location: The longitude, latitude, and radius we are centering our search around
            "37.8716,-122.2727,1km"
    Returns:
        list: A list of Dictonary objects, each representing one tweet."""
    import tweepy
    try:
        auth = tweepy.OAuthHandler(keys["consumer_key"], keys["consumer_secret"])
        auth.set_access_token(keys["access_token"], keys["access_token_secret"])
        api = tweepy.API(auth)
        tweets = [t._json for t in tweepy.Cursor(api.search,q="#" + hashtag,
                                                 location = location,lang="en").items(count)]
    except TweepError as e:
        logging.warning("There was a Tweepy error. Double check your API keys and try again.")
        logging.warning(e)
    return tweets

def write_data(dataset, path):
    """Saves a list of data to a file in the local filesystem. Extension
    must be .json.

    Args:
        dataset (list): A list of data objects (of type Dictionary) to
          be saved.
        path (str): The place where the data will be saved.

    Returns:
        None"""
    import json
    with open(path, "w") as f:        
        json.dump(tweets, f)
        
def read_data(path):
    """Loads data that have previously been saved as a json file.
    
    Calling read_data(path) after write_data(dataset, path)
    will produce the same list of tweets.
    
    Args:
        path (str): The place where the data were saved.

    Returns:
        list: A list of Dictionary objects, each representing one dataset."""
    import json
    with open(path, "r") as f:
        tweets = json.load(f)
    return tweets

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
        df (DataFrame): a single-column collection of tweets indexed by tweet ID.
        lex (DataFrame): a sentiment lexicon containing one column "polarity". The row indices
            of this df must be words."""
    df = df[['cleaned']]
    tidy_format = df.T.iloc[0].str.split(expand=True).stack().reset_index()
    tidy_format = tidy_format.set_index('id').rename(columns={'level_1': 'num', 0: 'word'})
    pol = tidy_format.merge(lex, how='left', left_on='word', right_index=True)
    return pol.groupby(pol.index).agg({'polarity': sum})