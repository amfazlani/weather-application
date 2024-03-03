# README

This README would normally document whatever steps are necessary to get the
application up and running.

An application that uses openweathermap API to get weather data by coordinates.

Things you may want to cover:

# Ruby Version
  ruby 2.6.3

# Rails version
  Rails 6.1.7.4 

# System dependencies

  This application utilizes the 'https://openweathermap.org/' Weather API. Plesse ensure you have an ENV var set named 'OPEN_WEATHER_API_KEY' which is the API found in developer console.
  
# Configuration

# Database creation

  bin/rake db:create
  bin/rake db:migrate

# How to run the test suite: 
  bundle exec rspec


# Services (job queues, cache servers, search engines, etc.)
  All cache is stored under '/tmp/caching-dev.txt'

# Run App
 
  npm install
  bin/rake db:create
  bin/rake db:migrate

  rails server
