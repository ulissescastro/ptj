require 'model/shared_behaviors'

describe PTJ::Tag do
  before :all do
    PTJ::Model.migrate_all! unless PTJ::Model.migrated?
    PTJ::Tag.destroy!
  end

  after :all do
    PTJ::Tag.destroy!
  end

  context "validity" do
    before :each do 
      @ctime = Time.now
      @obj = PTJ::Tag.new(:tag => 'foo')
    end

    after :each do 
      @obj.destroy if @obj.saved?
    end

    it_should_behave_like "a valid ptj model"
    
  end
end

