""" Utility functions for City Planning 101 Twitter API lab.

These functions have been adapted from Data 100 course materials.
"""

def load_keys(path):
    """Loads your Twitter authentication keys from a file on disk.
    
    Args:
        path (str): The path to your key file.  The file should
          be in JSON format and look like this (but filled in):
            {
                "consumer_key": "<your Consumer Key here>",
                "consumer_secret":  "<your Consumer Secret here>",
                "access_token": "<your Access Token here>",
                "access_token_secret": "<your Access Token Secret here>"
            }
    
    Returns:
        dict: A dictionary mapping key names (like "consumer_key") to
          key values."""
    
    import json
    with open(path) as f:
        keys = json.load(f)
    return keys

def validate_authentication(keys):
    """Tests that keys work. 
    
    Args:
        keys (dict): A Python dictionary with Twitter authentication
          keys (strings), like this (but filled in):
            {
                "consumer_key": "<your Consumer Key here>",
                "consumer_secret":  "<your Consumer Secret here>",
                "access_token": "<your Access Token here>",
                "access_token_secret": "<your Access Token Secret here>"
            }
    
    Returns:
        Nothing, prints out a message based on if the keys are valid or not.
    """
    import tweepy
    from tweepy.error import TweepError
    import logging
    try:
        auth = tweepy.OAuthHandler(keys["consumer_key"], keys["consumer_secret"])
        auth.set_access_token(keys["access_token"], keys["access_token_secret"])
        api = tweepy.API(auth)
        print("The keys are valid. Your username is:", api.auth.get_username())
    except TweepError as e:
        logging.warning("There was a Tweepy error. Double check your API keys and try again.")
        logging.warning(e)
    
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

def save_tweets(tweets, path):
    """Saves a list of tweets to a file in the local filesystem. Extension
    must be .json.

    Args:
        tweets (list): A list of tweet objects (of type Dictionary) to
          be saved.
        path (str): The place where the tweets will be saved.

    Returns:
        None"""
    import json
    with open(path, "w") as f:        
        json.dump(tweets, f)
        
def load_tweets(path):
    """Loads tweets that have previously been saved as a json file.
    
    Calling load_tweets(path) after save_tweets(tweets, path)
    will produce the same list of tweets.
    
    Args:
        path (str): The place where the tweets were be saved.

    Returns:
        list: A list of Dictionary objects, each representing one tweet."""
    import json
    with open(path, "r") as f:
        tweets = json.load(f)
    return tweets

def get_user_tweets_with_cache(user_account_name, keys_path):
    """Get recent tweets from one user, loading from a disk cache if available.
    
    The first time you call this function, it will download tweets by
    a user.  Subsequent calls will not re-download the tweets; instead
    they'll load the tweets from a save file in your local filesystem.
    All this is done using the functions you defined in the previous cell.
    This has benefits and drawbacks that often appear when you cache data:
    
    +: Using this function will prevent extraneous usage of the Twitter API.
    +: You will get your data much faster after the first time it's called.
    -: If you really want to re-download the tweets (say, to get newer ones,
       or because you screwed up something in the previous cell and your
       tweets aren't what you wanted), you'll have to find the save file
       (which will look like <something>_recent_tweets.pkl) and delete it.
    
    Args:
        user_account_name (str): The Twitter handle of a user, without the @.
        keys_path (str): The path to a JSON keys file in your filesystem.
    """
    ds_tweets_save_path = '{}_recent_tweets.pkl'.format(user_account_name)
    if not Path(ds_tweets_save_path).is_file():
        tweets = download_recent_tweets_by_user(user_account_name, load_keys(keys_path))
        save_tweets(tweets, ds_tweets_save_path)
        
    return load_tweets(ds_tweets_save_path)

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

def clean_tweets(s):
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