require 'net/http'
require 'nokogiri'

class TwitterScrapper
    attr_reader :tweets, :profile_stats, :username
    def initialize(url)
        url_uri = URI(url)
        req = Net::HTTP::get(url_uri)
        @doc = Nokogiri::HTML(req)
        @tweets = []
        @profile_stats = ""
        @username = ""
    end#mtd initialize

    def extract_username
        profile_name = @doc.search(".ProfileHeaderCard-name > a")
        @username = profile_name.first.inner_text
    end#mtd extract_username

    def extract_tweets
        profile_tweets = @doc.search(".tweet")
        profile_tweets.pop
        profile_tweets.each do |tweet|
            aux = ""
            aux1 = ""
            fecha = tweet.css(".stream-item-header span._timestamp.js-short-timestamp").inner_text
            aux += fecha + ".: "

            texto = tweet.css("p.TweetTextSize.js-tweet-text.tweet-text").inner_text
            aux += texto + " "
            @tweets << aux

            retweet = tweet.css(".ProfileTweet-actionCountForPresentation").first.text
            aux1 += "Retweets:" + retweet + ","

            favorite = tweet.css(".ProfileTweet-actionCountForPresentation").last.text
            aux1 += " Favorites:" + favorite
            @tweets << aux1
        end
    end#mtd extract_tweets

    def extract_stats
        profile_stats = @doc.search(".ProfileNav")
        siguiendo = ""
        profile_stats.each do |stats|
            number_tweets = stats.css(".ProfileNav-value").first.text
            @profile_stats += "Tweets: " + number_tweets + ", "

            siguiendo = stats.css(".ProfileNav-item.ProfileNav-item--following").inner_text
            siguiendo = siguiendo.split(" ")
            siguiendo = siguiendo.delete_at(1)
            @profile_stats += "Siguiendo: #{siguiendo}, "

            seguidores = stats.css(".ProfileNav-item.ProfileNav-item--followers").inner_text
            seguidores = seguidores.split(" ")
            seguidores = seguidores.delete_at(1)
            @profile_stats += "Seguidores: #{seguidores}, "

            me_gusta = stats.css(".ProfileNav-item.ProfileNav-item--favorites").inner_text
            me_gusta = me_gusta.split(" ")
            me_gusta = me_gusta[-1]
            @profile_stats += "Favoritos: #{me_gusta}"
        end
    end#mtd extract_stats

    def board_profile
        profile_stats_hash = []

        puts "Username: #{@username}"
        puts "----------------------------------------------------------------------------"
        puts "Stats: #{@profile_stats}"
        puts "----------------------------------------------------------------------------"
        puts "Tweets:"
        @tweets.each_with_index do |tweet, index|
                if index % 2 == 0 && index != 0
                    puts "\n"
                end                
                puts tweet
        end
        puts "\n"
    end



end#class TwitterScrapper

prueba = TwitterScrapper.new('https://twitter.com/AquiEnCortoTV')
prueba.extract_username
prueba.extract_tweets
prueba.extract_stats
p prueba.board_profile

