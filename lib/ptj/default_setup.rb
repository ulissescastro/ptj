# This is a default setup file you can 
# require as in "require 'ptj/default_setup'"
# it will automatically use default settings
# for the configuration and database if they
# are not specified in the configuration file.
require 'ptj'

PTJ::Env.read_config
PTJ::Model.setup! unless PTJ::Model.setup?

