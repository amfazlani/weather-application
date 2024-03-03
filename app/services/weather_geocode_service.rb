# This service is responsible for converting an address to lat/lon coordinates.

class WeatherGeocodeService
  attr_reader :query, :data

  EXPIRATION_FOR_CACHE = 30.minute.freeze

  def initialize(options={})
    @query = options[:query]
  end

  def perform
    fetch_coordinates
  end

  private

  def fetch_coordinates
    cache_key = "weather_data_#{query}"

    weather_data = Rails.cache.fetch(cache_key, expires_in: EXPIRATION_FOR_CACHE) do
      begin
        data_from_zipcode = handle_response(find_by_zipcode)
        data_from_name = handle_response(find_by_name)
      rescue StandardError => exception
        # log exception to error loggger (ie. Rollbar, etc) in a production environment.
        # For right now raise exception

        raise exception
      end

      @data = data_from_zipcode || data_from_name.flatten
    end
  end

  def find_by_zipcode
    # api documentation can be found at https://openweathermap.org/api/geocoding-api

    uri = URI("http://api.openweathermap.org/geo/1.0/zip?zip=#{query}&limit=1&appid=#{ENV['OPEN_WEATHER_API_KEY']}")

    Net::HTTP.get_response(uri)
  end

  def find_by_name
    # api documentation can be found at https://openweathermap.org/api/geocoding-api

    uri = URI("http://api.openweathermap.org/geo/1.0/direct?q=#{query}&limit=1&appid=#{ENV['OPEN_WEATHER_API_KEY']}")

    Net::HTTP.get_response(uri)
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      return JSON.parse(response.body)
    when Net::HTTPUnauthorized # specifcally check for invalid authorization
      # log exception to error loggger (ie. Rollbar, etc) in production environment.
      # For right now raise api key error message.

      raise 'Invalid API Key'
    when Net::HTTPNotFound
      # handle other Net:HTTP errors outisde of authorization
      # log exception to error loggger (ie. Rollbar, etc) in production environment.
      return nil
    else
       raise JSON.parse(response.body)['message']
    end
  end
end
