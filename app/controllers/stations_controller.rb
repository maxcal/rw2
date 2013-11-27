class StationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index, :measures, :search]
  authorize_resource :except => [:show, :index, :measures, :search]
  before_action :set_station, only: [:edit, :update, :destroy]

  # GET /stations
  # GET /stations.json
  def index
    @stations = @all_stations
  end

  # GET /stations/1
  # GET /stations/1.json
  def show
    @station = Station.friendly.find(params[:id])
    @measures = @station.measures
    @chart_min = 0
    @chart_max = 20
  end

  # GET /stations/new
  def new
    @station = Station.new
  end

  # GET /stations/1/edit
  def edit
  end

  # POST /stations
  # POST /stations.json
  def create
    @station = Station.new(station_params)

    respond_to do |format|
      if @station.save
        format.html { redirect_to @station, notice: 'Station was successfully created.' }
        format.json { render action: 'show', status: :created, location: @station }
      else
        format.html { render action: 'new' }
        format.json { render json: @station.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stations/1
  # PATCH/PUT /stations/1.json
  def update
    respond_to do |format|
      if @station.update(station_params)

        format.html { redirect_to @station, notice: 'Station was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @station.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stations/1
  # DELETE /stations/1.json
  def destroy
    @station.destroy
    respond_to do |format|
      format.html { redirect_to stations_url }
      format.json { head :no_content }
    end
  end

  # GET /stations/:staton_id/measures
  def measures
    @station = Station.friendly.find(params[:station_id])
    @measures = @station.measures
  end

  # DELETE /stations/:staton_id/measures
  def destroy_measures
    @station = Station.friendly.find(params[:station_id])
    Measure.delete_all("station_id = #{@station.id}")
    respond_to do |format|
      format.html { redirect_to station_url(@station) }
      format.json { head :no_content }
    end
  end

  # GET stations/search?lat=x&lon=x&radius
  def search
    lat = params[:lat]
    lon = params[:lon]
    radius = params[:radius] || 20
    @stations = Station.near([lat, lon], radius, :units => :km)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_station
      @station = Station.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def station_params
      params.require(:station).permit(:id, :name, :hw_id, :latitude, :longitude, :user_id, :slug)
    end
end