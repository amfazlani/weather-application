class WeatherController < ApplicationController
  def index
    weather_geocode_service.perform

    respond_to do |format|

      format.html # show.html.erb

      format.json { render json: weather_geocode_service.data, status: 200 }
    end
  end

  def get_weather_data
    weather_kit_service.perform

    respond_to do |format|

      format.html # show.html.erb

      format.json { render json: { data: weather_kit_service.data, icon: weather_kit_service.icon_url }, status: 200 }
    end
  end

  private

  def weather_geocode_service
    if params[:zip]
      @weather_geocode_service ||= WeatherGeocodeZipcodeService.new({query: params[:zip]})
    else
      @weather_geocode_service ||= WeatherGeocodeCityService.new({query: params[:city]})
    end
  end

  def weather_kit_service
    @weather_kit_service ||= WeatherKitService.new(params[:lat], params[:lon])
  end
end
