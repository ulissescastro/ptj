require 'model/shared_behaviors'

describe PTJ::Password do
  before :each do
    PTJ::Model.migrate_all! unless PTJ::Model.migrated?
    PTJ::Password.destroy!
  end

  after :each do
    PTJ::Password.destroy!
  end

  context "basic functionality" do
    before :each do
      @ctime = Time.now
      @obj = PTJ::Password.create(:password => "password", :pw_hash => "abchash")
    end

    it_should_behave_like "a valid ptj model"

    context "valid categorization of passwords" do
      it("should have the correct upper-case letter value") { PTJ::Password.classify_passwords("Upper")[:upper].should == true }
      it("should not have the correct upper-case letter value") { PTJ::Password.classify_passwords("upper")[:upper].should == false }

      it("should have the correct lower-case letter value") { PTJ::Password.classify_passwords("lower")[:lower].should == true }
      it("should not have the correct lower-case letter value") { PTJ::Password.classify_passwords("LOWER")[:lower].should == false }

      it("should have the correct numeric value") { PTJ::Password.classify_passwords("Numeric123")[:number].should == true }
      it("should not have the correct numeric value") { PTJ::Password.classify_passwords("Numeric!@#")[:number].should == false }

      it("should have the correct special character value") { PTJ::Password.classify_passwords("Special!@#")[:special].should == true }
      it("should not have the correctspecial character value") { PTJ::Password.classify_passwords("Special123")[:special].should == false }
    end


    context "valid size of passwords" do
      it("should have a size of 1") { PTJ::Password.new(:password => "a").size.should == 1}
      it("should have a size of 10") { PTJ::Password.new(:password => "abcdefghij").size.should == 10}
      it("should have a size of 20") { PTJ::Password.new(:password => "abcdefghijklmnopqrst").size.should == 20}
    end
  end

end



