# NB! when getting a station use the Friendly ID method Station.friendly.find(params[:id])
# Stations can use either slug or id as param
class Station < ActiveRecord::Base

  # relations
  belongs_to :user, inverse_of: :stations
  has_many  :measures, inverse_of: :station, counter_cache: true
  has_many :recent_measures, -> { order('created_at ASC').limit(10) }, class_name: 'Measure'

   # constraints
  validates_uniqueness_of :hw_id
  validates_presence_of :hw_id
  validates_numericality_of :speed_calibration
  validates_numericality_of :balance, allow_blank: true

  # geolocation
  geocoded_by :name
  reverse_geocoded_by :latitude, :longitude

  #callbacks
  before_validation :set_timezone!
  after_initialize :set_timezone!

  # Attribute aliases
  alias_attribute :lat, :latitude
  alias_attribute :lon, :longitude
  alias_attribute :lng, :longitude
  alias_attribute :owner, :user
  attr_accessor :zone
  attr_accessor :current_measure

  # Scopes
  scope :visible, -> { where(show: true) }

  # callbacks
  after_save :update_measure_speed_calibration,
             :if => lambda { |station| station.speed_calibration_changed? }

  # Get measures since N time ago
  # If no measures are found we fetch from last_measure_received_at
  # Measures are then calibrated
  def get_calibrated_measures(since = 12.hours.ago)
     mrs = measures.where("created_at >= ?", since).order("measures.created_at ASC")

     # If there are no recent measures we go back `since` time from last_measure_received_at to find measures
     if mrs.length < 1 && self.last_measure_received_at?
       mrs = measures.where("created_at >= ?", self.last_measure_received_at - (Time.now - since)).order("measures.created_at ASC")
     end

     mrs.each do |m|
       m.calibrate!
     end
     mrs
  end

  # Setup default values for new records
  after_initialize do
    if self.new_record?
      self.speed_calibration = 1
    end
  end

  # Lookup timezone via lat/lng
  def lookup_timezone
    self.zone = Timezone::Zone.new(:latlon => [self.lat, self.lon])
    self.zone.zone
  end

  # Lookup and set timezone
  # Also catches any errors caused by Timezone and logs them
  def set_timezone!
    if self.timezone.nil? and !self.latitude.nil? and !self.longitude.nil?
      # Lookup timezone and catch errors due to geonames not answering
      begin
        self.timezone = self.lookup_timezone
      rescue Timezone::Error::Base => e
        logger.warn e.message
      end
    elsif self.timezone and self.zone.nil?
      self.zone = Timezone::Zone.new( zone: self.timezone )
    end
  end

  # Use FriendlyId to create easily "pretty urls"
  extend FriendlyId
  friendly_id :name, :use => [:slugged, :history]

  # Generate a slug from name if none is given when creating station
  def should_generate_new_friendly_id?
    if !slug?
      name_changed?
    else
      false
    end
  end

  def current_measure
    measures.first unless @current_measure.presence
  end

  def measures?
    self.measures.present?
  end

  def self.send_low_balance_alerts stations = Station.all()
    stations.each do |station|
      station.check_balance
    end
  end

  # Rake task which periodically tests the status of each station.
  # @param stations array
  def self.check_all_stations stations = Station.all
    stations.each do |s|
      s.check_status!
    end
  end

  def time_to_local time
    self.zone.nil? ? time : zone.time(time)
  end

  def update_measure_speed_calibration
    self.measures.update_all(speed_calibration: self.speed_calibration)
  end

  # do heuristics if station is down
  def should_be_down?
      Measure.where({station_id: id}).since(24.minutes.ago).order(created_at: :desc).count  < 3
  end

  def check_status!
    if should_be_down?
      unless down?
        update_attribute('down', true)
        notify_down
      end
    else
      if down?
        update_attribute('down', false)
        notify_up
      end
    end
  end

  # Log and send notifications that station is down
  def notify_down

    logger.warn "Station alert: #{name} is now down"
    # Allows tests without user
    if user.present?
      StationMailer.notify_about_station_down(user, self)

      # create UI notification.
      Notification.create(
          user: self.user,
          level: :warn,
          message: "#{name} is down.",
          event: "station_down"
      )
    end
  end

  # Log and send notifications that station is up
  def notify_up
    logger.info "Station alert: #{name} is now up"

    # Allows tests without user
    if user.present?
      StationMailer.notify_about_station_up(user, self)
      Notification.create(
          user: self.user,
          level: :info,
          message: "#{name} is up.",
          event: "station_up"
      )
    end
  end

  # Send notifications if station balance is low
  # @return boolean true for ok balance, false if balance is low
  def check_balance
    if balance < 15
      Rails.logger.info "#{name} has a low balance, only #{balance} kr left."

      message = "#{name} has a low balance, only #{balance} kr left."

      # Check if there have been notifications of this event
      notified = Notification
        .where(message: message)
        .where("created_at >= ?", 12.hours.ago)
        .count > 0

      StationMailer.notify_about_low_balance(user, self) unless notified

      Notification.create(
          user: self.user,
          level: :info,
          message: message,
          event: "station_low_balance"
      )
      false
    else
      true
    end
  end

end
