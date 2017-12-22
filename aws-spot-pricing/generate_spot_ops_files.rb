#!/usr/bin/env ruby

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'lib/price_grabber'
require 'lib/ops_file_creator'
require 'pp'
require 'optparse'

# The following regions are skipped because they don't offer all the instance types in the cloud config
IGNORED_REGIONS = ['ca-central-1','eu-west-2','eu-west-3']

class Configuration
  attr_accessor :cloud_config, :region
  def initialize
    @cloud_config = @region = nil
  end
  def validate
    raise '--cloud-config must be specified' if cloud_config.nil?
    raise '--aws-region must be specified' if region.nil?
    return true
  end
end

configuration = Configuration.new

opt_parser = OptionParser.new do |opts|
  opts.on("--cloud-config PATH", "Path to your cloud configuration") { |v| configuration.cloud_config = v }
  opts.on("--aws-region REGION", "AWS region to use spot prices for") { |v| configuration.region = v }
end.parse!

configuration.validate

raise "Cannot find cloud config at #{configuration.cloud_config}" unless File.exists?(configuration.cloud_config)
cloud_config = File.read(configuration.cloud_config)

aws_prices = PriceGrabber.new.prices

regions = configuration.region.casecmp('all') ? aws_prices.keys - IGNORED_REGIONS : [configuration.region]

regions.each do |region|
  ops_file_creator = OpsFileCreator.new(cloud_config: cloud_config, region: region, prices: aws_prices)
  File.write("output/aws_spot_prices-#{region}.yml", ops_file_creator.create)
end
