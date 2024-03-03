# This service is responsible for converting an address to lat/lon coordinates.

class WeatherKitService
  attr_reader :lat, :lon, :data, :icon

  def initialize(lat, lon)
    @lat = lat
    @lon = lon
  end

  def perform
    fetch_weather_data
  end

  def icon_url
    return unless data && data['weather']

    @icon ||= "http://openweathermap.org/img/w/#{data['weather'].pop['icon']}.png"
  end

  private

  def fetch_weather_data
    begin
      response = fetch_from_api

      case response
      when Net::HTTPSuccess
        parsed_response = JSON.parse(response.body)
      when Net::HTTPUnauthorized # specifcally check for invalid authorization
        # log exception to error loggger (ie. Rollbar, etc) in production environment.
        # For right now raise api key error message.

        raise 'Invalid API Key'
      else 
        # handle other Net:HTTP errors outisde of authorization
        # log exception to error loggger (ie. Rollbar, etc) in production environment.
        raise JSON.parse(response.body)['message']
      end
    rescue StandardError => exception
      # log exception to error loggger (ie. Rollbar, etc) in a production environment.
      # For right now raise exception

      raise exception
    end

    @data = parsed_response # returnes hash of coordinates or nil object
  end

  def fetch_from_api
    # api documentation can be found at https://openweathermap.org/api/geocoding-api

    uri = URI("https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=-#{lon}&appid=#{ENV['OPEN_WEATHER_API_KEY']}&units=imperial")

    Net::HTTP.get_response(uri)
  end
end
