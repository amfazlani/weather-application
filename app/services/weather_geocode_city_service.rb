# This service is responsible for converting a city name to lat/lon coordinates.

class WeatherGeocodeCityService
  attr_reader :query, :data

  EXPIRATION_FOR_CACHE = 30.minute.freeze
  API_SECRET = ENV['OPEN_WEATHER_API_KEY']

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
      handle_response(find_by_city)
    end
  end

  def find_by_city
    # api documentation can be found at https://openweathermap.org/api/geocoding-api

    uri = URI("http://api.openweathermap.org/geo/1.0/direct?q=#{query}&limit=10&appid=#{API_SECRET}")

    Net::HTTP.get_response(uri)
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      return JSON.parse(response.body).uniq {|cord| cord['name']}
    when Net::HTTPUnauthorized # specifcally check for invalid authorization
      # log exception to error loggger (ie. Rollbar, etc) in production environment.
      # For right now raise api key error message.

       raise OpenWeatherError.new('Invalid API Key')
    when Net::HTTPNotFound
      # log exception to error loggger (ie. Rollbar, etc) in production environment.
      # For right now raise not found error message.
      raise OpenWeatherError.new('Not Found')
    else
       # handle other Net:HTTP errors outisde of authorization
       raise OpenWeatherError.new(JSON.parse(response.body)['message'])
    end
  end
end
