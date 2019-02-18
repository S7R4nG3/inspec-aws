# frozen_string_literal: true

require 'aws_backend'

class AwsSubnet < AwsResourceBase
  name 'aws_subnet'
  desc 'Verifies settings for an AWS VPC Subnet'

  example "
    describe aws_subnet(subnet_id: 'subnet-12345678') do
      it { should exist }
      its('cidr_block') { should eq '10.0.1.0/24' }
    end
  "

  def initialize(opts = {})
    # Call the parent class constructor
    opts = { subnet_id: opts } if opts.is_a?(String) # this preserves the original scalar interface
    super(opts)
    validate_parameters([:subnet_id])
    raise ArgumentError, 'You must provide a subnet_id to aws_subnet.' if opts[:subnet_id].nil? || opts[:subnet_id].empty?
    raise ArgumentError, 'aws_subnet Subnet ID must be in the format "subnet-" followed by 8 hexadecimal characters.' if opts[:subnet_id] !~ /^subnet\-[0-9a-f]{8}/
    @display_name = opts[:subnet_id]
    filter = { name: 'subnet-id', values: [opts[:subnet_id]] }
    catch_aws_errors do
      @resp = @aws.compute_client.describe_subnets({ filters: [filter] })
      @subnet = @resp.subnets[0].to_h
      create_resource_methods(@subnet)
    end
  end

  def available?
    @subnet[:state]=='available'
  end

  def exists?
    !@subnet.empty?
  end

  def default_for_az?
    @subnet[:default_for_az]
  end

  def mapping_public_ip_on_launch?
    @subnet[:map_public_ip_on_launch]
  end

  def assigning_ipv_6_address_on_creation?
    @subnet[:assign_ipv_6_address_on_creation]
  end

  def to_s
    "VPC Subnet #{@display_name}"
  end
end