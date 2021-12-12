# frozen_string_literal: true
require 'spec_helper'

describe AffairsOfState do
  describe "with a simple configuration" do
    class Pie < ActiveRecord::Base
      affairs_of_state :active, :inactive, :cancelled
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

    it "should have the statuses method with the nil default" do
      expect(Pie.statuses).to eq(["active", "inactive", "cancelled"])
    end

    it "should have the statuses method" do
      expect(Pie.statuses(:status)).to eq(["active", "inactive", "cancelled"])
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

    it "should know the accessors" do
      expect(Pie2.new(status: nil, super_status: "inactive").inactive?).to be(true)
    end

    it "should know the setters" do
      instance = Pie2.create!(status: nil, super_status: "inactive")
      expect(instance.active!).to be(true)
      expect(instance.super_status).to eq("active")
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
      expect(Pie4.statuses).to eq(["on", "off"])
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
      expect(->{ class Pie8 < ActiveRecord::Base ; affairs_of_state :new ; end }).to raise_error(ArgumentError, "Affairs of State: 'new' is not a valid status")
    end
  end

  describe "multiple invocations" do
    class Pie9 < ActiveRecord::Base
      self.table_name = "pies"

      affairs_of_state :active, :inactive
      affairs_of_state :moderated, :unmoderated, column: :super_status
    end

    it "declares two status columns" do
      p = Pie9.new
      p.inactive!
      p.unmoderated!
      expect(p).to be_inactive
      expect(p).to be_unmoderated
    end

    it "raises if called twice on the same column" do
      expect {
        class Pie < ActiveRecord::Base
          self.table_name = "pies"

          affairs_of_state :active, :inactive
          affairs_of_state :moderated, :unmoderated
        end
      }.to raise_error(ArgumentError)
    end

    it "raises if called twice with the same status in both" do
      expect {
        class Pie < ActiveRecord::Base
          self.table_name = "pies"

          affairs_of_state :active, :inactive
          affairs_of_state :dormant, :active, column: :super_status
        end
      }.to raise_error(ArgumentError)
    end

    it "raises if statuses is called with no argument" do
      expect {
        Pie9.statuses
      }.to raise_error(ArgumentError)
    end

    it "returns the statuses for the column" do
      expect(Pie9.statuses(:status)).to eq(["active", "inactive"])
      expect(Pie9.statuses("super_status")).to eq(["moderated", "unmoderated"])
    end

    it "raises if statuses_for_select is called with no argument" do
      expect {
        Pie9.statuses_for_select
      }.to raise_error(ArgumentError)
    end

    it "returns the statuses_for_select for the column" do
      expect(Pie9.statuses_for_select(:status)).to eq([["Active", "active"], ["Inactive", "inactive"]])
      expect(Pie9.statuses_for_select("super_status")).to eq([["Moderated", "moderated"], ["Unmoderated", "unmoderated"]])
    end
  end
end
