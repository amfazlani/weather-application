class WeatherController < ApplicationController
  def index
    weather_geocode_zipcode_service.perform

    respond_to do |format|

      format.html # show.html.erb

      format.json { render json: weather_geocode_zipcode_service.data, status: 200 }
    end
  end

  def get_weather_data
    data = WeatherKitService.new(params[:lat], params[:lon]).perform
    
    respond_to do |format|

      format.html # show.html.erb

      format.json { render json: data, status: 200 }
    end
  end

  private

  def weather_geocode_zipcode_service
    if params[:zip]
      @weather_geocode_service ||= WeatherGeocodeZipcodeService.new({query: params[:zip]})
    else
      @weather_geocode_service ||= WeatherGeocodeCityService.new({query: params[:city]})
    end
  end
end
