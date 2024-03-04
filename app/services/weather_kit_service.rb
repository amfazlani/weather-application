# This service is responsible for fetching weather data by lat/lon coordinates

class WeatherKitService
  attr_reader :lat, :lon, :data, :icon

  EXPIRATION_FOR_CACHE = 30.minutes.freeze
  API_SECRET = ENV['OPEN_WEATHER_API_KEY'].freeze

  def initialize(lat, lon)
    @lat = lat
    @lon = lon
  end

  def perform
    fetch_weather_data
  rescue StandardError => exception
    raise OpenWeatherError.new(exception.message)
  end

  def icon_url
    return unless data && data['weather']

    @icon ||= "http://openweathermap.org/img/w/#{data['weather'].pop['icon']}.png"
  end

  private

  def fetch_weather_data
    cache_key = !Rails.env.test? ? "weather_data_#{lat.to_s}_#{lon.to_s}" : Time.now.to_i

    @data = Rails.cache.fetch(cache_key, expires_in: EXPIRATION_FOR_CACHE) do
      handle_response(find_by_coordinates)
    end
  end

  def find_by_coordinates
    # api documentation can be found at https://openweathermap.org/api/geocoding-api

    Net::HTTP.get_response(api_url)
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
       JSON.parse(response.body)
    when Net::HTTPUnauthorized # specifcally check for invalid authorization
      # log exception to error loggger (ie. Rollbar, etc) in production environment.
      # For right now raise api key error message.

      raise OpenWeatherError.new('Invalid API Key')
    when Net::HTTPNotFound
      # log exception to error loggger (ie. Rollbar, etc) in production environment.

      raise OpenWeatherError.new('Not Found')
    else 
      # log exception to error loggger (ie. Rollbar, etc) in production environment.

      raise OpenWeatherError.new(JSON.parse(response.body)['message'])
    end
  end

  def api_url
    URI("https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&appid=#{API_SECRET}&units=imperial")
  end
end
