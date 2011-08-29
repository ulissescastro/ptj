require 'dm-core'
require 'dm-types'
require 'dm-migrations'
require 'dm-transactions'
require 'dm-validations'
require 'dm-serializer'
require 'dm-timestamps'
require 'dm-aggregates'


require 'ptj/environment'

module PTJ

  module Model
    module FixtureTable
      def fixture_table?
        true
      end
    end

  
    require 'ptj/model/password'
    require 'ptj/model/tag'

    # Sets up the model using with the currently configured db_conn 
    # configuration.
    def self.setup!
      DataMapper::Logger.new($stdout, :debug) if Env::CONFIG[Env::KEY_DEBUG]
      DataMapper.setup(:default, Env::CONFIG[Env::KEY_DB_CONN])
      DataMapper.finalize
      @setup = true
    end

    # @return True,False
    #   Indicates whether the the model has been set up yet with the 
    #   setup! method.
    def self.setup?
      @setup == true
    end

    # Updates the model schema in the current database.
    # 
    # @return Object
    #   Returns the return value from DataMapper.auto_upgrade!
    def self.migrate_all!
      setup! unless setup?
      # use a non-destructive schema migration across the whole model
      ret=DataMapper.auto_upgrade!
      @migrated = true
      return ret
    end

    # @return True,False
    #   Indicates whether the current model has been migrated 
    #   (via auto_upgrade).
    def self.migrated?
      @migrated == true
    end

  end
end



