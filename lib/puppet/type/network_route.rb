require 'ipaddr'
require_relative '../../puppet_x/voxpupuli/utils.rb'

Puppet::Type.newtype(:network_route) do
  @doc = 'Manage non-volatile route configuration information'

  include PuppetX::Voxpupuli::Utils

  ensurable

  newparam(:name) do
    isnamevar
    desc 'The name of the network route'
  end

  newproperty(:network) do
    isrequired
    desc 'The target network address'
    validate do |value|
      unless 'default' == value
        a = PuppetX::Voxpupuli::Utils.try { IPAddr.new(value) }
        raise("Invalid value for network: #{value}") unless a
      end
    end
  end

  newproperty(:netmask) do
    isrequired
    desc 'The subnet mask (in cidr style) to apply to the route'

    validate do |value|
      unless value.length < 3 || PuppetX::Voxpupuli::Utils.try { IPAddr.new('255.255.255.255/' + value.to_s) }
        raise("Invalid value for argument netmask: #{value}")
      end
    end
  end

  newproperty(:gateway) do
    isrequired
    desc 'The gateway to use for the route'

    validate do |value|
      begin
        IPAddr.new(value)
      rescue ArgumentError
        raise("Invalid value for gateway: #{value}")
      end
    end
  end

  newproperty(:interface) do
    isrequired
    desc 'The interface to use for the route'
  end

  # `:options` provides an arbitrary passthrough for provider properties, so
  # that provider specific behavior doesn't clutter up the main type but still
  # allows for more powerful actions to be taken.
  newproperty(:options, required_features: :provider_options) do
    desc 'Provider specific options to be passed to the provider'

    validate do |value|
      raise ArgumentError, "#{self.class} requires a string for the options property" unless value.is_a?(String)
    end
  end
end
