
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

    # sequence of upper, lower, special, and number
    property :sequence,       String,
      :default => lambda{|this,p| this.password.gsub(/[a-z]/,"l").gsub(/[A-Z]/,"u").gsub(/[0-9]/,"n").gsub(/[^uln]/,"s") }

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
      when /^[^0-9\p{Punct}]+$/ 
        lower = upper = true
      when /^[^A-Z\p{Punct}]+$/
        lower = number = true
      when /^[^A-Z0-9]+$/
        lower = special = true
      when /^[^a-z\p{Punct}]+$/
        upper = number = true
      when /^[^a-z0-9]+$/
        upper = special = true
      when /^[^a-zA-Z]+$/
        number = special = true
      when /^[^\p{Punct}]+$/
        lower = upper = number = true
      when /^[^a-z]+$/
        upper = number = special = true
      when /^[^A-Z]+$/
        lower = number = special = true
      when /^[^0-9]+$/
        lower = upper = special = true
      else
        lower = number = special = upper = true unless pass == ""
      end
      
      return {:lower => lower, :upper => upper, :special => special, :number => number}
    end


    def self.import(file, parser, tags = [])
      actual_tags = []
      tags.each do |tag|
        tag = Tag.get(tag) || Tag.create(:tag => tag)
        actual_tags << tag
      end
      file = Pathname.new(file) unless file.is_a?(Pathname)
      lines = file.readlines
      counter = 0
      threshold = 2000
      queue_array = []
      lines.each do |line|  
        begin
          parsed = parser.parse_line(line.chomp)
          queue_array = queue_array << parsed
          while (queue_array.size > threshold)
            do_transaction(queue_array[0..(threshold-1)], actual_tags)
            queue_array = queue_array[(threshold)..queue_array.size]
          end
        rescue StandardError => e
          puts "[**] Error encountered when importing '#{line.chomp}'\n[*] Message: #{e.message}"
          next
        end
      end
      begin
        do_transaction(queue_array, actual_tags)
      rescue StandardError => e
        puts "[**] Error encountered when importing '#{line.chomp}'\n[*] Message: #{e.message}"
      end
    end

    private

    def self.do_transaction(array, tags)
      Password.transaction do
        array.each do |myhash|
          next if myhash[:mypass].to_s.empty?
          pass = Password.create( :password => myhash[:mypass], 
                                  :pw_hash => myhash[:myhash] || "", 
                                  :tags => tags)
        end
      end
    end
 

  end
end

