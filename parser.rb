# Pars
require 'open-uri'
require 'nokogiri'

# Files
require 'json'
require 'csv'

class ParserCoin

    URL = 'https://coinmarketcap.com'

    def get_html
        doc = Nokogiri::HTML(URI.open(URL).read)
        @document = doc

        #puts "Step - 1 - Get HTML - Done!"
    end

    def get_links

        get_link = []
        get_link = @document.css('a.cmc-link').map { |link| URL + link['href'] }
        @no_sorted_link = get_link

        #puts get_link
        #puts "Step - 2 - Get link coins - Done!"
    end

    def sorted_links
       
        i = 0
        sorted_link = []
    
        while i < 210
    
            # If link have '/currencies/' work whih this link
            if @no_sorted_link[i].include?('/currencies/')
                
                # If link have '/markets/' dont work with this link
                if @no_sorted_link[i].include?('/markets/')
                    i = i + 1
    
                # If link not have '/markets/' work whih this link
                else
                    sorted_link.push(@no_sorted_link[i])
                    i = i + 1
                end
    
            else
                i = i + 1
            end
    
        end
    
        # Delete double elements from array
        sorted_link = sorted_link.uniq
        @link = sorted_link
        
        #puts sorted_link
        #puts "Step - 3 - Sorted link coins - Done!"
    
    end

    def get_coins_info

        tempJSON = []
        i=0

        while i <= 99

            coin_url = @link[i].to_s
            coin_doc = Nokogiri::HTML(URI.open(coin_url).read)

            # Name coin
            name_coin = coin_doc.css('h2.h1___3QSYG')
                full_name_coin = name_coin.children[0].text
                short_name_coin = name_coin.children[1].text

            # Link coin
            link_coin = @link[i]

            # Rank
            rating_coin = coin_doc.css('div.namePillPrimary___2-GWA').text
                rating_coin = rating_coin.split('#')[1]

            # Price / 24Price
            price_coin = coin_doc.css('div.priceValue___11gHJ').text
                price_coin = price_coin.split('$')[1] + " $" 

            price_24h = coin_doc.css('span.highLowValue___GfyK7')
                min_price_24h = price_24h.children[0].to_s
                    min_price_24h = min_price_24h.split('$')[1] + " $"

                max_price_24h = price_24h.children[1].to_s
                    max_price_24h = max_price_24h.split('$')[1] + " $"

            volume24 = coin_doc.css('div.statsValue___2iaoZ').children[2].to_s
                volume24 = volume24.split('$')[1] + " $"

            # Capitalation 
            capitalization = coin_doc.css('div.statsValue___2iaoZ').children[0].to_s
                capitalization = capitalization.split('$')[1] + " $"

        tempJSON.push({        
            field_fname: full_name_coin,
            field_sname: short_name_coin,
            field_link: link_coin,
            field_rating: rating_coin,
            field_price: price_coin,
            field_mim24: min_price_24h,
            field_max24: max_price_24h,
            field_vol24: volume24,
            field_capital: capitalization
        })
 
            i = i + 1

        end

        @tempJSON = tempJSON

        #puts JSON.pretty_generate tempJSON
        #puts "Step - 4 - Get info of coins - Done!
    end

    def create_json_file
        output_JSON = 'outputJSON.json'

        File.open(output_JSON,"w") do |f|
            f.write(@tempJSON.to_json)
        end

        #puts "Step - 5 - Create JSON file - Done!"
    end

    def create_csv_file

        output_CSV = 'outputCSV.csv'

        CSV.open(output_CSV, "w") do |csv|
                # Header
                csv << ['Full Name Coin', 'Short Name Coin', 'Coin`s link', 'Rank', 'Price', 'Min Price 24h', 'Max Price 24h', 'Volume 24h', 'Caritalization']
            JSON.parse(File.open("outputJSON.json").read).each do |hash|
                csv << hash.values
            end
        end

        #puts "Step - 6 - Create CVS file - Done!"
    end

    def start

        puts "Start pars CoinMarketCap.com"
            get_html
            get_links
            sorted_links
            get_coins_info
            create_json_file
            create_csv_file
        puts "Done!"

    end

end
 
obj = ParserCoin.new
obj.start
