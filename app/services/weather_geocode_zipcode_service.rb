# This service is responsible for converting an address to lat/lon coordinates.

class WeatherGeocodeZipcodeService
  attr_reader :query, :data

  EXPIRATION_FOR_CACHE = 30.minute.freeze
  API_SECRET = ENV['OPEN_WEATHER_API_KEY']

  def initialize(options={})
    @query = options[:query]
  end

  def perform
    fetch_coordinates
  end

  private

  def fetch_coordinates
    cache_key = "weather_data_#{query}"

    @data = Rails.cache.fetch(cache_key, expires_in: EXPIRATION_FOR_CACHE) do
      handle_response(find_by_zipcode)
    end
  end

  def find_by_zipcode
    # api documentation can be found at https://openweathermap.org/api/geocoding-api

    uri = URI("http://api.openweathermap.org/geo/1.0/zip?zip=#{query}&limit=1&appid=#{API_SECRET}")

    Net::HTTP.get_response(uri)
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      return JSON.parse(response.body)
    when Net::HTTPUnauthorized # specifcally check for invalid authorization
      # log exception to error loggger (ie. Rollbar, etc) in production environment.
      # For right now raise api key error message.

      raise OpenWeatherError.new('Invalid API Key')
    when Net::HTTPNotFound
      # handle other Net:HTTP errors outisde of authorization
      # log exception to error loggger (ie. Rollbar, etc) in production environment.
      raise OpenWeatherError.new('Not Found')
    else
       raise OpenWeatherError.new(JSON.parse(response.body)['message'])
    end
  end
end
