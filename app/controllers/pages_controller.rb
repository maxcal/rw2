class PagesController < ApplicationController

  skip_before_filter :authenticate_user!
  skip_authorization_check

  def home
    @stations = @all_stations
  end

  def products

  end
end
