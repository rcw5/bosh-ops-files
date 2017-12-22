require 'json'
require 'open-uri'

PRICE_URL = "http://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js"

class PriceGrabber
  def prices
    price_list = {}
    prices = open(PRICE_URL).read
    # AWS returns a Javascript object here so needs to be wrangled into something
    # Ruby can understand
    prices.chomp!
    prices.gsub!(/\*.*\n/, "")
    prices.chomp!(");")
    prices.gsub!("/    callback(","")
    prices.strip!
    prices.gsub!(/(\w+)\s*:/, '"\1":')
    price_json = JSON.parse(prices)

    price_json.fetch('config').fetch('regions').each do |p|
      region = p.fetch('region')
      price_list[region] = prices_for_region(p)
    end
    price_list
  end

  private

  def prices_for_region(region_price_list)
    price_list = {}
    region_price_list.fetch('instanceTypes').each do |instance_type|
      instance_type.fetch('sizes').each do |size|
        instance_size =  size.fetch('size')
        price = size.fetch('valueColumns')[0].fetch('prices').fetch('USD')
        price_list[instance_size] = price.to_f
      end
    end
    price_list
  end


end

