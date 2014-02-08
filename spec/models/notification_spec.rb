require "spec_helper"

describe Notification do

  it { should belong_to :user }
  it { should respond_to :event }
  it { should respond_to :message }
  it { should respond_to :read }
  it { should respond_to :level }

  describe "level" do
    it "should not validate a value not in LEVELS_RFC_5424" do
      subject.level = 52
      expect(subject.valid?).to be_false
    end
  end

  describe "#level=" do
    it "maps symbols to numeric values" do
      subject.level = :warning
      expect(subject.level).to eq 300
    end
  end

  describe "#level_to_symbol" do
    it "converts key to string" do
      subject.level = 300
      expect(subject.level_to_sym).to eq :warning
    end
  end

  describe "#level_to_s" do
    it "converts key to string" do
      subject.level = :warning
      expect(subject.level_to_s).to eq "warning"
    end
  end

end