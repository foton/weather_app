# frozen_string_literal: true

require 'httparty'
require 'json'
require_relative './abstract.rb'

module Weather
  module Provider
    class OpenWeather < Weather::Provider::Abstract
      WEATHER_URI = 'https://api.openweathermap.org/data/2.5/weather'
      CELSIUS_UNITS = 'metric'
      FAHRENHEIT_UNITS = 'imperial'
      # default unit is Kelvin!

      attr_accessor :options

      def initialize(api_key)
        super
        @api_key = api_key
        @options = { units: CELSIUS_UNITS, appid: @api_key }
        @result = nil
      end

      def current_weather_for(city_name_or_id)
        parse_city(city_name_or_id)
        call_open_weather
        @result
      end

      private

      def call_open_weather
        response = HTTParty.get(WEATHER_URI, query: query)
        @result = (response.code == 404 ? not_found_report : build_report_from(response))
      end

      def query
        options.merge(city_id ? { id: city_id } : { q: city_name })
      end

      def build_report_from(response)
        extract_data_hash_from(response.body)

        report_with(city_name: ow_city_name,
                    city_id: ow_city_id,
                    temperature_in_celsius: ow_temperature_in_celsius,
                    temperature_in_fahrenheit: ow_temperature_in_fahrenheit,
                    time_in_utc: ow_generation_time_in_utc)
      end

      def extract_data_hash_from(response_body)
        @data_hash = JSON.parse(response_body)
      end

      def ow_city_name
        @data_hash['name'].to_s + ',' + @data_hash['sys']['country'].to_s
      end

      def ow_city_id
        @data_hash['id'].to_i
      end

      def ow_temperature_in_celsius
        temp_in_celsius? ? @data_hash['main']['temp'] : nil
      end

      def ow_temperature_in_fahrenheit
        temp_in_fahrenheit? ? @data_hash['main']['temp'] : nil
      end

      def ow_generation_time_in_utc
        Time.at(@data_hash['dt'].to_i).utc
      end

      def temp_in_celsius?
        @options[:units] == CELSIUS_UNITS
      end

      def temp_in_fahrenheit?
        @options[:units] == FAHRENHEIT_UNITS
      end
    end
  end
end
