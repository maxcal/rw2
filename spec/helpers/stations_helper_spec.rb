require 'rails_helper'

describe StationsHelper, type: :helper do

  let(:station) { build_stubbed(:station) }

  describe "#clear_observations_button" do

    subject(:button) { helper.clear_observations_button(station) }

    it "should have the correct classes" do
      expect(button).to have_selector 'a.tiny.button.alert'
    end

    it "has the correct text" do
      expect(button).to have_selector "a", text: "Clear all observations for this station?"
    end

    it 'has method=DELETE' do
      expect(button).to have_selector 'a[data-method="delete"]'
    end

    it "has a data-confirm attibute" do
      expect(button).to match /data-confirm\=\"*.?\"/
    end
  end

  describe "#station_header" do
    subject(:heading) { helper.station_header(station) }
    it "contains the stations name" do
      expect(heading).to eq (station.name)
    end

    context "when station is not active" do
      let(:station) { build_stubbed(:station, status: :deactivated) }
      subject(:heading)  { helper.station_header(station) }
      it "shows the stations status" do
        expect(heading).to have_selector 'em', text: 'deactivated'
      end
    end
  end

  describe "#station_coordinates" do
    let(:station) { build_stubbed(:station, lat: 50, lon: 40) }
    subject(:data_attrs) { helper.station_coordinates(station) }
    it { is_expected.to match 'data-lat="50"' }
    it { is_expected.to match 'data-lng="40"' }
  end

  describe "#readable_duration" do
    let(:duration) { 1.hour + 5.minutes + 10.seconds }
    it "includes hours seconds and minutes" do
      expect(helper.readable_duration(duration)).to eq '01:05:10'
    end
  end
end
