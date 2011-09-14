
module PTJ

  class Password
    include DataMapper::Resource
    include Model::FixtureTable

    # id value for every entry
    property :id,         Serial

    # password
    property :password,    String, :required => true

    # hash of password
    property :pw_hash,         String

    # time this was added to database
    property :created_at,          DateTime, :writer => :private

    # upper-case letters in password
    property :upper,         Boolean,
      :default => lambda{|this,p| self.classify_passwords(this.password)[:upper] }

    # lower-case letters in password
    property :lower,         Boolean,
      :default => lambda{|this,p| self.classify_passwords(this.password)[:lower] }

    # numbers in password
    property :number,         Boolean,
      :default => lambda{|this,p| self.classify_passwords(this.password)[:number] }

    # special characters in password
    property :special,         Boolean,
      :default => lambda{|this,p| self.classify_passwords(this.password)[:special] }

    # length of the password
    property :size,         Integer,
      :default => lambda{|this,p| this.password.size }

    # Tags associated with a sample
    has n, :tags, :through => Resource

    # Classify an individual password based on the levels of complexities 
    # present. 
    #
    # @param pass
    #   Password to classify.
    #
    # @return Hash
    #   :lower => value, :upper => value, :special => value, :number => value
    def self.classify_passwords(pass)
      pass = pass.to_s
      lower = false
      upper = false
      special = false
      number = false

      case pass
      when /^[a-z]+$/
        lower = true
      when /^[^a-zA-Z0-9]+$/
        special = true
      when /^[A-Z]+$/
        upper = true 
      when /^[0-9]+$/
        number = true
      when /^([a-zA-Z]*([a-z]+[A-Z]+|[A-Z]+[a-z]+)[a-zA-Z]*)$/
        lower = upper = true
      when /^([a-z0-9]*([a-z]+[0-9]+|[0-9]+[a-z]+)[a-z0-9]*)$/
        lower = number = true
      when /^(([a-z]|[^a-zA-Z0-9])*([a-z]+[^a-zA-Z0-9]+|[^a-zA-Z0-9]+[a-z]+)([a-z]|[^a-zA-Z0-9])*)$/
        lower = special = true
      when /^([0-9A-Z]*([0-9]+[A-Z]+|[A-Z]+[0-9]+)[0-9A-Z]*)$/
        upper = number = true
      when /^(([A-Z]|[^a-zA-Z0-9])*([A-Z]+[^a-zA-Z0-9]+|[^a-zA-Z0-9]+[A-Z]+)([A-Z]|[^a-zA-Z0-9])*)$/
        upper = special = true
      when /^(([0-9]|[^a-zA-Z0-9])*([0-9]+[^a-zA-Z0-9]+|[^a-zA-Z0-9]+[0-9]+)([0-9]|[^a-zA-Z0-9])*)$/
        number = special = true
      when /^([a-zA-Z0-9]*([a-z]+[A-Z]+[0-9]+|[a-z]+[0-9]+[A-Z]+|[A-Z]+[a-z]+[0-9]+|[A-Z]+[0-9]+[a-z]+|[0-9]+[A-Z]+[a-z]+|[0-9]+[a-z]+[A-Z]+)+[a-zA-Z0-9]*)$/
        lower = upper = number = true
      when /^(([^a-zA-Z0-9]|[A-Z0-9])*([^a-zA-Z0-9]+[A-Z]+[0-9]+|[^a-zA-Z0-9]+[0-9]+[A-Z]+|[A-Z]+[^a-zA-Z0-9]+[0-9]+|[A-Z]+[0-9]+[^a-zA-Z0-9]+|[0-9]+[A-Z]+[^a-zA-Z0-9]+|[0-9]+[^a-zA-Z0-9]+[A-Z]+)+([^a-zA-Z0-9]|[A-Z0-9])*)$/
        upper = number = special = true
      when /^(([^a-zA-Z0-9]|[a-z0-9])*([^a-zA-Z0-9]+[a-z]+[0-9]+|[^a-zA-Z0-9]+[0-9]+[a-z]+|[a-z]+[^a-zA-Z0-9]+[0-9]+|[a-z]+[0-9]+[^a-zA-Z0-9]+|[0-9]+[a-z]+[^a-zA-Z0-9]+|[0-9]+[^a-zA-Z0-9]+[a-z]+)+([^a-zA-Z0-9]|[a-z0-9])*)$/
        lower = number = special = true
      when /^(([^a-zA-Z0-9]|[a-zA-Z])*([^a-zA-Z0-9]+[a-z]+[A-Z]+|[^a-zA-Z0-9]+[A-Z]+[a-z]+|[a-z]+[^a-zA-Z0-9]+[A-Z]+|[a-z]+[A-Z]+[^a-zA-Z0-9]+|[A-Z]+[a-z]+[^a-zA-Z0-9]+|[A-Z]+[^a-zA-Z0-9]+[a-z]+)+([^a-zA-Z0-9]|[a-zA-Z])*)$/
        lower = upper = special = true
      else
        lower = number = special = upper = true unless pass == ""
      end
      
      return {:lower => lower, :upper => upper, :special => special, :number => number}
    end

  end
end

