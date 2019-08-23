# frozen_string_literal: true

require 'sinatra'
require_relative './weather.rb'

provider = Weather::Provider::OpenWeather.new(ENV['OPEN_WEATHER_API_KEY'])
stored_columns = %i[city_name city_id temperature_in_celsius time_in_utc]
storage = Weather::Storage::File.new(filepath: 'weather_data.json',
                                     stored_attributes: stored_columns)
weatherman = Weather::Weatherman.new(provider, storage)
city_name = 'Olomouc,CZ'

get '/' do
  weatherman.current_weather_for(city_name)
  @average_report = weatherman.average_temperature_for(city_name)
  erb :index
end

