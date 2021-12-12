# frozen_string_literal: true
require 'spec_helper'

describe AffairsOfState::Config do
  let(:config) do
    AffairsOfState::Config.new(
      statuses: statuses,
      column: column,
      allow_blank: allow_blank,
      scopes: scopes,
      if: if_condition
    )
  end
  let(:column) { "state" }
  let(:statuses) { [ :created, [ :destroyed ] ] }
  let(:allow_blank) { "sure" }
  let(:scopes) { nil }
  let(:if_condition) { "false" }

  subject { config }

  describe "accessors" do
    it "has :column" do
      expect(subject.column).to eq(column)
    end

    it "has :allow_blank" do
      expect(subject.allow_blank).to be(true)
    end

    it "has :scopes" do
      expect(subject.scopes).to be(false)
    end

    it "has :if" do
      expect(subject.if).to eq(if_condition)
    end

    it "has :statuses and converts to strings and flattens" do
      expect(subject.statuses).to eq(["created", "destroyed"])
    end
  end

  context "with invalid status" do
    let(:statuses) { [ "new" ] }

    it "makes sure no invalid statuses are allowed" do
      expect { subject }.to raise_error(ArgumentError, "Affairs of State: 'new' is not a valid status")
    end
  end
end
