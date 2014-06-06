require 'spec_helper'

describe AffairsOfState do

  describe "with a simple configuration" do
    class Pie < ActiveRecord::Base
      affairs_of_state :active, :inactive, :cancelled
    end

    it "should set the constant" do
      expect(Pie::STATUSES).to eq(["active", "inactive", "cancelled"])
    end

    it "should validate the column is set" do
      expect(Pie.new(status: nil)).to_not be_valid
    end

    it "should validate that we're not setting it to something stupid" do
      expect(Pie.new(status: "delicious_pie")).to_not be_valid
    end

    describe "boolean methods" do
      it "should find the set status" do
        p = Pie.new status: "active"
        expect(p.active?).to be_truthy
      end

      it "should not find if a different status is set" do
        p = Pie.new status: "inactive"
        expect(p.cancelled?).to be_falsy
      end
    end

    describe "update methods" do
      it "should set the value" do
        p = Pie.create! status: "active"
        expect(p.inactive!).to be_truthy
        expect(p.status).to eq("inactive")
      end
    end

    it "should provide a method to pass to dropdowns" do
      expect(Pie.statuses_for_select).to eq([["Active", "active"], ["Inactive", "inactive"], ["Cancelled", "cancelled"]])
    end

    describe "scopes" do
      it "should have a finder to match the status name" do
        Pie.create! status: "active"
        Pie.create! status: "inactive"
        Pie.create! status: "active"
        Pie.create! status: "cancelled"

        expect(Pie.active.size).to eq(2)
        expect(Pie.inactive.size).to eq(1)
        expect(Pie.cancelled.size).to eq(1)
      end
    end

    after(:each) do
      Pie.destroy_all
    end
  end

  describe "with a non-standard column name" do
    class Pie2 < ActiveRecord::Base
      self.table_name = "pies"

      affairs_of_state :active, :inactive, column: :super_status
    end

    it "should validate the column is set" do
      expect(Pie2.new(status: nil, super_status: "active")).to be_valid
    end
  end

  describe "without validations" do
    class Pie3 < ActiveRecord::Base
      self.table_name = "pies"

      affairs_of_state :active, :inactive, allow_blank: true
    end

    it "should validate the column is set" do
      expect(Pie3.new(status: nil)).to be_valid
    end
  end

  describe "with an array rather than *args" do
    class Pie4 < ActiveRecord::Base
      self.table_name = "pies"

      affairs_of_state [:on, :off]
    end

    it "should work too if that's what floats your boat" do
      expect(Pie4::STATUSES).to eq(["on", "off"])
    end
  end

  describe "without the scopes" do
    class Pie5 < ActiveRecord::Base
      self.table_name = "pies"

      affairs_of_state :active, :inactive, scopes: false
    end

    it "should work too if that's what floats your boat" do
      expect(Pie5).to_not respond_to(:active)
    end
  end

  describe "with a conditional proc" do
    class Pie6 < ActiveRecord::Base
      self.table_name = "pies"

      affairs_of_state :active, :inactive, if: lambda{|p| p.is_going_to_validate }

      attr_accessor :is_going_to_validate
    end

    it "should enforce the validation if the :if param is true" do
      p = Pie6.new
      p.is_going_to_validate = true
      p.status = "pie"
      expect(p).to_not be_valid
    end

    it "should not enforce the validation if the :if param evaluates to false" do
      p = Pie6.new
      p.is_going_to_validate = false
      p.status = "pie"
      expect(p).to be_valid
    end
  end

  describe "with a conditional method name" do
    class Pie7 < ActiveRecord::Base
      self.table_name = "pies"

      affairs_of_state :active, :inactive, if: :validation_method?

      attr_accessor :is_going_to_validate

      def validation_method?
        self.is_going_to_validate
      end
    end

    it "should enforce the validation if the :if param is true" do
      p = Pie7.new
      p.is_going_to_validate = true
      p.status = "pie"
      expect(p).to_not be_valid
    end

    it "should not enforce the validation if the :if param evaluates to false" do
      p = Pie7.new
      p.is_going_to_validate = false
      p.status = "pie"
      expect(p).to be_valid
    end
  end

  describe "invalid status name" do
    it "should raise a good warning" do
      expect(->{ class Pie8 < ActiveRecord::Base ; affairs_of_state :new ; end }).to raise_error("Affairs of State: 'new' is not a valid status")
    end
  end

end
