require 'rails_helper'

describe ObservationsController, type: :controller do

  let(:station) {  create(:station) }
  let(:observation) { create(:observation, station: station) }
  let(:valid_attributes) { attributes_for(:observation, station_id: station.id) }

  before(:each) { logout :user }

  describe "POST 'create'" do


    it "checks station status" do
      expect_any_instance_of(Station).to receive(:check_status!)
      post :create, { station_id: station, observation: valid_attributes }
    end

    context "with valid attributes" do
      it "should create a new observation" do
        expect {
          post :create, {station_id: station, observation: valid_attributes }
        }.to change(Observation, :count).by(1)
      end
    end

    context "with yaml format" do
      it "sends HTTP success" do
        post :create, { station_id: station, observation: valid_attributes }
        expect(response.code).to eq "200"
      end
    end

    it "updates station last_observation_received_at" do
      post :create, { station_id: station, observation: valid_attributes }
      expect(assigns(:station).last_observation_received_at).to eq assigns(:observation).created_at
    end

  end

  describe "GET index" do

    let(:station) { create(:station, speed_calibration: 0.5) }
    let!(:observations) { [ create(:observation, station: station, speed: 10) ] }

    it "enables CORS" do
      get :index, station_id: station.to_param
      expect(response.headers['Access-Control-Allow-Origin']).to eq "*"
    end

    context "when request is HTML" do

      it "uses the page param to paginate observations" do
        # Stub the chain to set up expection
        allow_any_instance_of(Station).to receive(:observations).and_return(Observation)
        allow(Observation).to receive(:order).and_return(Observation)

        expect(Observation).to receive(:paginate).with(page: "2").and_return([].paginate)
        get :index, station_id: station.to_param, page: "2"
      end
    end

    context "when request is JSON" do

      before :each do
        get :index, station_id: station.to_param, format: 'json'
      end

      it "assigns station" do
        expect(assigns(:station)).to be_a(Station)
      end

      it "assigns observations" do
        expect(assigns(:observations).to_a).to include observations.first
      end

      it "calibrates observations" do
        expect(assigns(:observations).first.speed).to eq 5
      end
    end

    describe "http caching" do

      subject(:last_response) do
        get :index, station_id: station.to_param, format: 'json'
        response
      end

      it "should set the proper max age" do
        allow_any_instance_of(Station)
                .to receive(:last_observation_received_at)
                .and_return(2.minutes.ago)
        expect(last_response.cache_control[:max_age]).to eq 180.seconds
      end

      context "on the first request" do
        before { get :index, station_id: station.to_param, format: 'json' }
        subject { response }

        its(:code){ is_expected.to eq '200' }
        its(:headers) { is_expected.to have_key 'ETag' }
        its(:headers) { is_expected.to have_key 'Last-Modified' }
      end
      context "on a subsequent request" do
        before do
          get :index, station_id: station.to_param, format: 'json'
          @etag = response.headers['ETag']
          @last_modified = response.headers['Last-Modified']
        end
        context "if it is not stale" do
          before do
            request.env['HTTP_IF_NONE_MATCH'] = @etag
            request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
          end

          describe '#code' do
            subject { super().code }
            it { is_expected.to eq '304' }
          end
        end
        context "if station has been updated" do
          before do
            station.observations.create(attributes_for(:observation))
            request.env['HTTP_IF_NONE_MATCH'] = @etag
            request.env['HTTP_IF_MODIFIED_SINCE'] = @last_modified
          end

          describe '#code' do
            subject { super().code }
            it { is_expected.to eq '200' }
          end
        end
      end
    end
  end

  describe "DELETE clear" do


    let(:action) { delete :clear, { station_id: station.to_param} }

    before :each do
      3.times do
        station.observations.create attributes_for(:observation)
      end
    end

    context "an unpriveleged user" do
      before { sign_in create(:user) }
      it "does not allow observations to be destoyed" do
        expect do
          action
        end.to_not change(Observation, :count)
      end
      it "does not allow observations to be destoyed" do
        expect do
          bypass_rescue
          action
        end.to raise_error Pundit::NotAuthorizedError
      end
    end

    context "when an admin" do
      before { sign_in create(:admin) }

      it "destroys the related observations" do
        action
        expect(Observation.where("station_id = #{station.id}").count).to eq 0
      end
      it "redirects to the station" do
        action
        expect(response).to redirect_to(station_url(station.to_param))
      end
    end
  end

  describe "DELETE 'destroy'" do

    let(:action) {  delete :destroy, {id: observation.to_param, station_id:  observation.station.to_param} }

    before do
      observation #lazy load observation
    end

    context "as unpriveleged user" do
      before { sign_in create(:user) }
      it "should not allow observations to be destoyed without authorization" do
        expect do
          action
        end.to_not change(Observation, :count)
      end
    end

    context "as admin" do
      before { sign_in create(:admin) }

      it "destroys the requested observation" do
        expect {
          action
        }.to change(Observation, :count).by(-1)
      end

      it "redirects to the observation list" do
        action
        expect(response).to redirect_to(station_observations_url(observation.station))
      end
    end
  end
end
