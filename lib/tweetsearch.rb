require 'rubygems'
require 'bundler/setup'
require 'twitter'

module TweetSearch
  class UserWord
    attr_reader :word, :tweet, :result
    
    def initialize(word)
      @word = word
    end
  
    # Fetch a Tweet containing the provided word and select another
    # random word from the Tweet.
    #
    # Returns the String word.
    def search!
      fetch_tweet
      select_word
    end

    private

    # Fetch a tweet from Twitter with the provided word.
    #
    # Returns the matching Twitter::Tweet.
    def fetch_tweet
      client = Twitter::Client.new.configure do |config|
        config.consumer_key = ENV['CONSUMER_KEY']
        config.consumer_secret = ENV['CONSUMER_SECRET']
        config.oauth_token = ENV['OAUTH_TOKEN']
        config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
      end

      # From https://github.com/sferik/twitter#configuration
      # 
      # searches through Twitter client to find the word from html form. Will only return the first tweet.
      @tweet = client.search(@word, :count => 1)
    end

    # Choose an appropriate word from the tweet.
    #
    # Returns the String newly selected word.
    def select_word
      @result = TweetSanitizer.new(@tweet).sanitized_words.sample(1)
    end
  end

  class TweetSanitizer
    def initialize(tweet)
      @tweet = tweet
    end

    
    def sanitized_words
      @words = @tweet.text.split(" ")

      remove_short_words
      remove_non_alpha_words

      @words
    end

    private

    def remove_short_words
      @words = @words.delete_if {|w| w.length < 4}
    end

    def remove_non_alpha_words
      @words.select! {|w| w.match(/^[a-zA-Z]+$/) }
    end
  end
end

#word_search = TweetSearch::UserWord.new('baseball').search!
#puts word_search.tweet.inspect
#puts word_search.result