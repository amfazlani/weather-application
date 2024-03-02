# This service is responsible for converting an address to lat/lon coordinates.

class WeatherGeocodeService
  attr_reader :city, :state, :zipcode, :data

  def initialize(options={})
    @city = options[:city]
    @state = options[:state]
    @zipcode = options[:zipcode]
  end

  def perform
    fetch_coordinates
  end

  private

  def fetch_coordinates
    begin
      response = fetch_coordinate_data

      case response
      when Net::HTTPSuccess
        parsed_response = JSON.parse(response.body).flatten.pop
      when Net::HTTPUnauthorized # specifcally check for invalid authorization
        # log exception to error loggger (ie. Rollbar, etc) in production environment.
        # For right now raise api key error message.

        raise 'Invalid API Key'
      else 
        # handle other Net:HTTP errors outisde of authorization
        # log exception to error loggger (ie. Rollbar, etc) in production environment.

        raise JSON.parse(response.body)
      end
    rescue StandardError => exception
      # log exception to error loggger (ie. Rollbar, etc) in a production environment.
      # For right now raise exception

      raise exception
    end

    @data = parsed_response # returnes hash of coordinates or nil object
  end

  def fetch_coordinate_data
    # api documentation can be found at https://openweathermap.org/api/geocoding-api

    uri = URI("http://api.openweathermap.org/geo/1.0/direct?q=#{city}, #{state}, #{zipcode}&limit=1&appid=#{ENV['OPEN_WEATHER_API_KEY']}")

    Net::HTTP.get_response(uri)
  end
end
