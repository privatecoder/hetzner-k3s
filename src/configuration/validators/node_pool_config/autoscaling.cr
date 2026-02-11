require "ipaddress"

require "../../models/node_pool"

class Configuration::Validators::NodePoolConfig::Autoscaling
  getter errors : Array(String)
  getter pool : Configuration::Models::NodePool

  def initialize(@errors, @pool)
  end

  def validate
    autoscaling_settings = pool.try(&.autoscaling)
    return unless autoscaling_settings && autoscaling_settings.enabled

    errors << "Autoscaling settings for pool #{pool.name} are invalid: max_instances must be greater than min_instances" if autoscaling_settings.max_instances <= autoscaling_settings.min_instances
    validate_subnet_ip_range(autoscaling_settings)
  end

  private def validate_subnet_ip_range(autoscaling_settings)
    subnet = autoscaling_settings.subnet_ip_range
    return if subnet.empty?

    IPAddress.new(subnet).network?
  rescue ArgumentError
    errors << "Autoscaling subnet #{subnet} for pool #{pool.name} is not a valid network in CIDR notation"
  end
end
