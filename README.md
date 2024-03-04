# WeatherApp

An application that retrieves current weather data by city and zipcode using the OpenWeatherMap API.

# Ruby Version
  `ruby 2.6.3`

# Rails version
  `Rails 6.1.7.4`

# NPM version
  `8.1.2`

# Node version
  `v16.13.1`

# System dependencies

  `This application utilizes the OpenWeatherMap API found at [OpenWeather API Documentation](https://openweathermap.org/current) Please ensure you have an ENV var named 'OPEN_WEATHER_API_KEY' which is the API Key found in the developer console. If this ENV var is not present, you will recieve an Invalid API Key Error`

  `This applicaton utilizes jQuery and Font-Awesome for the user interface`
  
# Database creation

  `bin/rake db:create`
  `bin/rake db:migrate`

# Services (job queues, cache servers, search engines, etc.)
  This application utilizes ActiveSupport::Cache::FileStore for caching. All cache is stored under '/tmp/caching-dev.txt

  Additional documentation for FileStore can be found at [FileStore Documentation](https://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html)

# Run App
  Run bundle to install all app dependencies:

  `bundle install`

  Run webpacker install:

  `bundle exec rails webpacker:install`

  Run npm install to add all javascript dependencies:

  `npm install`

  Create Database

  `bin/rake db:create`

  Migrate Database

  `bin/rake db:migrate`

  Run server at localhost:3000:

  `rails server`

# How to run the test suite:

  `bundle exec rspec`

