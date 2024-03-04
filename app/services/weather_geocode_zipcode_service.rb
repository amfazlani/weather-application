# This service is responsible for converting a zipcode to lat/lon coordinates.

class WeatherGeocodeZipcodeService
  attr_reader :query, :data

  EXPIRATION_FOR_CACHE = 30.minute.freeze
  API_SECRET = ENV['OPEN_WEATHER_API_KEY'].freeze

  def initialize(options={})
    @query = options[:query]
  end

  def perform
    fetch_coordinates
  rescue StandardError => exception
    raise OpenWeatherError.new(exception.message)
  end

  private

  def fetch_coordinates
    cache_key = !Rails.env.test? ? "weather_data_#{query}" : Time.now.to_i

    @data = Rails.cache.fetch(cache_key, expires_in: EXPIRATION_FOR_CACHE) do
      handle_response(find_by_zipcode)
    end
  end

  def find_by_zipcode
    # api documentation can be found at https://openweathermap.org/api/geocoding-api

    Net::HTTP.get_response(api_url)
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
      # log exception to error loggger (ie. Rollbar, etc) in production environment.

      raise OpenWeatherError.new('Not Found')
    else # handle other Net:HTTP errors outisde of authorization or not found
      raise OpenWeatherError.new(JSON.parse(response.body)['message'])
    end
  end

  def api_url
    URI("http://api.openweathermap.org/geo/1.0/zip?zip=#{query}&limit=1&appid=#{API_SECRET}")
  end
end
