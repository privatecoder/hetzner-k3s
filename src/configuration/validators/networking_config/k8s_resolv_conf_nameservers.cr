class Configuration::Validators::NetworkingConfig::K8sResolvConfNameservers
  getter errors : Array(String)
  getter nameservers : Array(String)

  def initialize(@errors, @nameservers)
  end

  def validate
    return if nameservers.size <= 2

    errors << "k8s_resolv_conf_nameservers supports at most 2 entries (k3s ignores additional nameservers)"
  end
end
