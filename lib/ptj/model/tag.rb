module PTJ

  class Tag
    include DataMapper::Resource
    include Model::FixtureTable

    # A textual tag name
    property :tag,          String, :key => true

    has n, :passwords,    :through => Resource

  end
end
