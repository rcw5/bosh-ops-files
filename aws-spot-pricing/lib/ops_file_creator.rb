require 'yaml'

class OpsFileCreator
  attr_reader :cloud_config, :region, :prices
  def initialize(cloud_config:, region:, prices:)
    raise 'No prices provided' if prices.nil?
    @cloud_config = YAML.load(cloud_config)
    @region = region
    @prices = prices
    raise "No prices provided for region #{region}" if prices[region].nil?
    raise 'No vm_types found in cloud config' if cloud_config['vm_types'].nil?
  end

  def create
    cloud_config.fetch('vm_types').map do |vm_type|
      instance_type = vm_type.fetch('cloud_properties').fetch('instance_type')
      name = vm_type.fetch('name')
      raise "No price found for instance #{instance_type} in region #{region}" if prices.fetch(region)[instance_type].nil?
      price = prices.fetch(region).fetch(instance_type)
      {
        "type" => "replace",
        "path" => "/vm_types/name=#{name}/cloud_properties/spot_bid_price?",
        "value" => price
      }
    end.to_yaml
  end
end
