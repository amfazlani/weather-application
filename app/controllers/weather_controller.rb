class WeatherController < ApplicationController
  def index
    weather_geocode_service = WeatherGeocodeService.new({query: params[:q]})

    weather_geocode_service.perform

    respond_to do |format|

      format.html # show.html.erb

      format.json { render json: weather_geocode_service.data }
    end
  end

  def get_weather_data
    data = WeatherKitService.new(params[:lat], params[:lon]).perform
    
    respond_to do |format|

      format.html # show.html.erb

      format.json { render json: data }
    end
  end
end
