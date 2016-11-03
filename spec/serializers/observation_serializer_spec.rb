# == Schema Information
#
# Table name: observations
#
#  id                :integer          not null, primary key
#  station_id        :integer
#  speed             :float
#  direction         :float
#  max_wind_speed    :float
#  min_wind_speed    :float
#  created_at        :datetime
#  updated_at        :datetime
#  speed_calibration :float
#
require 'rails_helper'

describe ObservationSerializer do

  let(:resource) { build_stubbed(:observation, created_at: Time.new(2000), station: build_stubbed(:station), direction: 5) }
  it_behaves_like 'a observation'

  describe '#cardinal' do
    subject { resource.cardinal }
    it { is_expected.to eq "N" }
  end

end
