require 'spec_helper'
shared_examples_for "a valid ptj model" do
  after :each do
    @obj.destroy if @obj.saved?
  end

  it "should be valid" do
    @obj.should be_valid
  end

  it "should save without problems" do
    @obj.save
    @obj.should be_saved
  end

  it "should be destroy-able" do
    @obj.save
    @obj.should be_saved
    @obj.destroy
    @obj.should be_destroyed
  end

end
