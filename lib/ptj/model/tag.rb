module PTJ

  class Tag
    include DataMapper::Resource
    include Model::FixtureTable

    # A textual tag name
    property :tag,          String, :key => true

    # An optional description of the tag.
    property :description,  Text

    property :created_at,       DateTime, :writer => :private 
    property :updated_at,       DateTime, :writer => :private 

    has n, :passwords,    :through => Resource

  end
end
