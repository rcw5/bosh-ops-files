require 'rspec'
require 'lib/price_grabber'

RSpec.describe PriceGrabber do

  let (:grabber) { PriceGrabber.new }
  let (:body) { <<-BODY
{
/*
 * This file is intended for use only on aws.amazon.com. We do not guarantee its availability or accuracy.
 *
 * Copyright 2017 Amazon.com, Inc. or its affiliates. All rights reserved.
 */
callback(
  config: {
    regions: [{
      region: "us-east-1",
      instanceTypes: [{
        sizes: [{
          size: "t2.nano",
          valueColumns: [{
            prices: {
              USD: "0.0058"
            }
          }]
        },{
        size: "t2.micro",
          valueColumns: [{
            prices: {
              USD: "51.5058"
            }
          }]
        }]
      }]
    }]
  }
});
BODY

  }
  it 'Gets Prices from AWS' do
    stub_request(:get, "http://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js").
      to_return(body: body)
    expect(grabber.prices.fetch('us-east-1')).to eq({"t2.nano"=> 0.0058, "t2.micro"=> 51.5058})
    assert_requested :get, "http://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js"
  end

  context 'When there are multiple AWS regions' do
    let (:body) { <<BODY
{
  config: {
    regions: [{
      region: "us-east-1",
      instanceTypes: [{
        sizes: [{
          size: "t2.nano",
          valueColumns: [{
            prices: {
              USD: "0.0058"
            }
          }]
        },{
        size: "t2.micro",
          valueColumns: [{
            prices: {
              USD: "51.5058"
            }
          }]
        }]
      }]
    }, {
      region: "mars-west-99",
      instanceTypes: [{
        sizes: [{
          size: "t2.tiny",
          valueColumns: [{
            prices: {
              USD: "10.0058"
            }
          }]
        },{
        size: "t2.huge",
          valueColumns: [{
            prices: {
              USD: "511.5058"
            }
          }]
        }]
      }]
    }]
  }
}
BODY
    }
    it 'Retreives prices for each region' do
      stub_request(:get, "http://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js").
      to_return(body: body)

      prices = grabber.prices
      expect(prices.fetch('us-east-1')).to eq({"t2.nano"=> 0.0058, "t2.micro"=> 51.5058})
      expect(prices.fetch('mars-west-99')).to eq({"t2.tiny"=> 10.0058, "t2.huge"=> 511.5058})
      assert_requested :get, "http://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js"
    end
  end
end
