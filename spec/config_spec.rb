require 'spec_helper'

describe AffairsOfState::Config do
  subject{ AffairsOfState::Config.new }

  describe "accessors" do
    let(:expected){ double }

    it "has :column" do
      subject.column = expected
      expect(subject.column).to eq(expected)
    end

    it "has :allow_blank" do
      subject.allow_blank = expected
      expect(subject.allow_blank).to eq(expected)
    end

    it "has :scopes" do
      subject.scopes = expected
      expect(subject.scopes).to eq(expected)
    end

    it "has :if" do
      subject.if = expected
      expect(subject.if).to eq(expected)
    end
  end

  describe "#statuses=" do
    it "converts to string" do
      subject.statuses = [:a, :b]
      expect(subject.statuses).to eq(["a", "b"])
    end

    it "flattens" do
      subject.statuses = ["a", [:b]]
      expect(subject.statuses).to eq(["a", "b"])
    end

    it "makes sure no invalid statuses are allowed" do
      expect(->{
        subject.statuses = [:new]
      }).to raise_error(ArgumentError, "Affairs of State: 'new' is not a valid status")
    end
  end
end
