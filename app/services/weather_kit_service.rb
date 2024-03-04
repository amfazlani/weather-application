# This service is responsible for fetching weather data by lat/lon coordinates

class WeatherKitService
  attr_reader :lat, :lon, :data, :icon

  EXPIRATION_FOR_CACHE = 30.minutes.freeze

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

    weather_data = Rails.cache.fetch(cache_key, expires_in: EXPIRATION_FOR_CACHE) do
      # api documentation can be found at https://openweathermap.org/api/geocoding-api
      uri = URI("https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&appid=#{ENV['OPEN_WEATHER_API_KEY']}&units=imperial")

      response = Net::HTTP.get_response(uri)

      case response
      when Net::HTTPSuccess
         @data = JSON.parse(response.body)
      when Net::HTTPUnauthorized # specifcally check for invalid authorization
        # log exception to error loggger (ie. Rollbar, etc) in production environment.
        # For right now raise api key error message.

        raise 'Invalid API Key'
      else 
        # log exception to error loggger (ie. Rollbar, etc) in production environment.

        raise JSON.parse(response)['message']
      end
    end
  end
end
