require 'sinatra'
require 'json'

module PTJ
  class Task 
    include DataMapper::Resource

    property :id,          Serial
    property :description, Text, :required => true
    property :is_done,     Boolean

    def url
      "/tasks/#{self.id}"
    end
    
    def to_json(*a)
      { 
        'guid'        => self.url, 
        'description' => self.description,
        'isDone'      => self.is_done 
      }.to_json(*a)
    end

    REQUIRED = [:description, :is_done]
  
    def self.parse_json(body)
      json = JSON.parse(body)
      ret = { :description => json['description'], :is_done => json['isDone'] }
      return nil if REQUIRED.find { |r| ret[r].nil? }
 
      ret 
    end

    

  end
end

