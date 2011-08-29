require 'pathname'
require 'yaml'

module PTJ
  # This module is used in bootstrapping and configuring the 
  # PTJ Environment.
  #
  # The "KEY_*" constants in this module specify configuration options
  # that can be used as hash keys via load_config or in the yara formatted
  # configuration file via read_config.
  #
  module Environment

    LIBROOT = Pathname.new(__FILE__).dirname.dirname.expand_path
    ROOTDIR = LIBROOT.dirname.expand_path
    DATADIR = ROOTDIR.join('data')

    PTJ_ENV = ((d=ENV['PTJ_ENV']) and not d.empty?)? d : nil

    CFGDIR = if (d=ENV['PTJ_CFGDIR'])
               Pathname.new(d) 
             elsif PTJ_ENV 
               ROOTDIR.join('etc', PTJ_ENV)
             else
               ROOTDIR.join('etc')
             end

    CFGFILE = (d=ENV['PTJ_CFGFILE'])? Pathname.new(d) : CFGDIR.join('config.yml')

    VERSION = File.read(ROOTDIR.join('VERSION'))
    VERS_MAJOR, VERS_MINOR, VERS_PATCH = VERSION.split('.',3).map{|n| n.to_i}

    # The 'db_url' configuration option 
    KEY_DB_CONN     = "db_conn"
    
    # The debug configuration option may be set to true or false. 
    # If debugging is enabled, certain features in spookt will emit extra
    # debugging information. The default value is false.
    KEY_DEBUG      = "debug"

    CONFIG = {
      KEY_DEBUG  =>  false,
      KEY_DB_CONN => "sqlite::memory:",
    }


    # The load config method will load new configuration settings from
    # a hash object. Note, the default configuration settings are overridden
    # by new values specified with this method. 
    #
    # Example:
    #
    #     # This example enables debugging...
    #     Spookt::Environment.load_config "debug" => true
    #
    # Note certain configuration variables are available such as LIBROOT,
    # DATADIR, ROOTDIR, CFGDIR, and can be accessed from config options by enclosing
    # them with the special character '$'. Any constant defined in Spookt::Environment
    # can be accessed this way, actually.
    #
    # Example:
    #
    #     # This example sets the samples directory as a subdirectory of
    #     # the DATADIR (this is the default, but this does it explicitly)
    #     Spookt::Environment.load_config "sample_dir" => "$DATADIR$/samples"
    #
    #
    def self.load_config(hash)
      hash.each do |k,v|
        if v.is_a?(String)
          v = v.gsub(/\$([A-Z][A-Z0-9_]*)\$/) do |v|
            var = $1
            if const_defined?(var)
              const_get(var).to_s
            else
              raise("Invalid variable referenced in configuration: #{v}")
            end
          end
        end

        CONFIG[k.to_s] = v
      end
    end

    class ConfigError < StandardError
    end

    # The load config method will load new configuration settings from
    # a yaml-formatted configuration file. Note, the default configuration 
    # settings are overridden by new values specified in the configuration
    # file.
    #
    # The yaml config data is treated as a ruby hash and passed directly to 
    # load_config. See load_config for more options.
    # 
    def self.read_config(file=CFGFILE)
      begin
        h = YAML.load_file(file) 
      rescue
        raise(ConfigError, "Error in file: #{file} -> #{$!}")
      end
      if h.is_a?(Hash)
        load_config(h)
      else
        raise(ConfigError, "invalid ptj config format for file: #{file}")
      end
    end

  end

  Env = Environment
    
end


