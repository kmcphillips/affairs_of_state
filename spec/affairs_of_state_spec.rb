require 'spec_helper'

describe AffairsOfState do

  describe "with a simple configuration" do
    class Pie < ActiveRecord::Base
      affairs_of_state :active, :inactive, :cancelled
    end

    it "should set the constant" do
      Pie::STATUSES.should == ["active", "inactive", "cancelled"]
    end

    it "should validate the column is set" do
      p = Pie.new :status => nil
      p.should_not be_valid
    end

    it "should validate that we're not setting it to something stupid" do
      p = Pie.new :status => "delicious_pie"
      p.should_not be_valid
    end

    describe "boolean methods" do
      it "should find the set status" do
        p = Pie.new :status => "active"
        p.active?.should be_true
      end

      it "should not find if a different status is set" do
        p = Pie.new :status => "inactive"
        p.cancelled?.should be_false
      end
    end

    describe "update methods" do
      it "should set the value" do
        p = Pie.create! :status => "active"
        p.inactive!.should be_true
        p.status.should == "inactive"
      end
    end

    it "should provide a method to pass to dropdowns" do
      Pie.statuses_for_select.should == [["Active", "active"], ["Inactive", "inactive"], ["Cancelled", "cancelled"]]
    end
  end

  describe "with a non-standard column name" do
    class Pie2 < ActiveRecord::Base
      self.table_name = "pies"

      affairs_of_state :active, :inactive, :column => :super_status
    end

    it "should validate the column is set" do
      p = Pie2.new :status => nil, :super_status => "active"
      p.should be_valid
    end
  end

  describe "without validations" do
    class Pie3 < ActiveRecord::Base
      self.table_name = "pies"

      affairs_of_state :active, :inactive, :allow_blank => true
    end

    it "should validate the column is set" do
      p = Pie3.new :status => nil
      p.should be_valid
    end
  end

  describe "with an array rather than *args" do
    class Pie4 < ActiveRecord::Base
      self.table_name = "pies"

      affairs_of_state [:on, :off]
    end    

    it "should work too if that's what floats your boat" do
      Pie4::STATUSES.should == ["on", "off"]
    end
  end

end
