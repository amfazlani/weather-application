class ApplicationController < ActionController::Base
  rescue_from OpenWeatherError do |exception|
    render json: { errors: exception.message, status: 422 }
  end
end
