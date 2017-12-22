require 'rspec'
require 'lib/ops_file_creator'

RSpec.describe OpsFileCreator do

  let(:price_list) { {"eu-west-1" => {"t2.micro" => 0.99, "t2.nano" => 1.99} } }
  let(:ops_file_creator) { OpsFileCreator.new(cloud_config: cloud_config, region: 'eu-west-1', prices: price_list) }
  let(:cloud_config) {
    <<-CONFIG
  vm_types:
  - cloud_properties:
      ephemeral_disk:
        size: 10240
        type: gp2
      instance_type: t2.micro
    name: default
  - cloud_properties:
      ephemeral_disk:
        size: 10240
        type: gp2
      instance_type: t2.nano
    name: minimal
    CONFIG
  }
  context '#create' do
    let(:expected_yaml) {
      <<-YAML
---
- type: replace
  path: "/vm_types/name=default/cloud_properties/spot_bid_price?"
  value: 0.99
- type: replace
  path: "/vm_types/name=minimal/cloud_properties/spot_bid_price?"
  value: 1.99
      YAML
    }
    it 'Creates an ops file for the given region using the price list' do
      expect(ops_file_creator.create).to eq(expected_yaml)
    end

    context 'Errors' do
      it 'Raises an error when no prices are provided' do
        expect { OpsFileCreator.new(cloud_config: cloud_config, region: 'eu-west-1', prices: nil ) }.to raise_error('No prices provided')
      end
      it 'Raises an error when prices cannot be found for the provided region' do
        expect { OpsFileCreator.new(cloud_config: cloud_config, region: 'eu-west-2', prices: price_list ) }.to raise_error('No prices provided for region eu-west-2')
      end
      it 'Raises an error when no VM types are given in the cloud_config' do
        expect { OpsFileCreator.new(cloud_config: "", region: 'eu-west-1', prices: price_list ) }.to raise_error('No vm_types found in cloud config')
      end
      context 'When a price is missing for a given instance type' do
        let(:price_list) { {"eu-west-1" => {"t2.micro" => 0.99 } } }
        it 'Raises an error' do
          expect { ops_file_creator.create }.to raise_error('No price found for instance t2.nano in region eu-west-1')
        end
      end
    end
  end

end
