# Include ruby tweaks
require_relative 'tools'
# Mother vagrant component model
require_relative "model/config"
require_relative "model/component"
require_relative "model/errors"

# Singleton to dispatch all plugin actions
class Facade
  # Map Plugin Class => Array of config keys
  PLUGINS_CONFIGS = {
    Base: false, # false give correct object with function base_config()
    Provider: [:project_name],
    Network: [:domain],
    Ansible: [:git],
    Fs: [:paths]
  }

  # Passing to each module vagrant object and part of the config struct
  def initialize(vagrant, dir, manala = true)
    $vagrant = vagrant # Vagrant object
    $__dir__ = dir # Keep Vagrantfile dir
    c = Config.new

    PLUGINS_CONFIGS.each do |plugin, cnf|
      require_relative "plugins/#{plugin.downcase}"
      configs_arg = [c.get(plugin.downcase)]
      cnf ? cnf.each { |param| configs_arg.push(c.get(param)) } : nil
      Object.const_get(plugin).new(*configs_arg)
    end
  end
  # end class VagrantBootstrap
end

# Add common fixes depending on actuals vagrant issues
# vagrant/vbox dhcp error (v2.2.7)
class VagrantPlugins::ProviderVirtualBox::Action::Network
  def dhcp_server_matches_config?(dhcp_server, config)
    true
  end
end
