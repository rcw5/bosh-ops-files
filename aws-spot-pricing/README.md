# BOSH Ops files for AWS Spot Instances

Running CF on AWS can be expensive, but there is an easy way to reduce the cost: spot instances. Spot instances cost a fraction of on-demand instances, and although AWS will terminate them if the spot price exceeds your bid price, this rarely happens.

More information here: https://www.cloudfoundry.org/using-aws-spot-instances-to-cut-the-cost-of-your-bosh-deployments/

To tell BOSH to use spot instances for a particular VM type simply assign a value to the `spot_bid_price` property in the cloud-config:

```
resource_pools:
  - name: large_ondemand
    cloud_properties:
      availability_zone: eu-west-1a
      instance_type: m2.xlarge
      spot_bid_price: 0.05
```

This script creates an ops file which you can use against a cloud-config to set the `spot_bid_price` for each instance equal to the on-demand cost for the given instance type in that region. You might not necessarily want to do this in production, but this is a great way to run a test environment for the lowest price possible.

## Using the ops files

### bbl

If using `bbl`, first run `bbl plan` with appropriate arguments then copy the relevant ops file for your AWS region into the `cloud-config` directory then run `bbl up`.

For existing deployments, copy the relevant file for your AWS region into the `cloud-config` directory then re-run `bbl up`.

### Something else

Target your bosh director and download the cloud config:

`bosh cloud-config > cloud-config.yml`

Interpolate the downloaded cloud-config with the relevant ops file for your region:

`bosh interpolate --ops-file output/aws_spot_prices-eu-west-1.yml cloud-config.yml > cloud-config-spot.yml`

Finally upload the cloud config

`bosh update-cloud-config cloud-config-spot.yml`

Either deploy CF now, or if you have an existing deployment then redeploy it using the new cloud config.

## Regenerating ops files

AWS might change their prices some day, or the bosh director cloud config for AWS might change.

If either do, get the latest cloud config from your director and run run `./generate_spot_ops_files.rb --cloud-config cloud-config.yml --aws-region all`

Updated ops files will be saved to the `output` directory.

## Permissions

Additional permissions may be required in order to successfully start spot instances. Without correct permissions in place any BOSH create_vm commands will fail with one of a series of different errors.

If using `bbl` drop `spot_permissions.tf` into your `terraform` directory then re-run `bbl up`.

