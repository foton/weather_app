# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/weather/providers/open_weather.rb'

module Weather
  module Provider
    class TestOpenWeatherProvider < Minitest::Test
      attr_reader :provider

      OLOMOUC_NAME = 'Olomouc,CZ'
      OLOMOUC_ID = 3_069_011

      def setup
        # we actually make real calls to OpenWeather API, to be sure have working provider
        # in other tests we are using Weather::Provider::Test
        @provider = Weather::Provider::OpenWeather.new(ENV['OPEN_WEATHER_API_KEY'])
      end

      def test_current_weather_for_city_name_should_return_weather_report
        result = provider.current_weather_for('Olomouc,cz')
        assert result.is_a?(Weather::Report)
        assert_equal OLOMOUC_NAME, result.city_name
        assert_equal OLOMOUC_ID, result.city_id
        assert result.temperature_in_celsius > -100
        assert result.temperature_in_fahrenheit > -100
        assert result.city_found?
        assert result.time_in_utc.is_a?(Time)
        assert result.time_in_utc < Time.now.utc
        assert_equal result.time_in_utc.utc, result.time_in_utc
      end

      def test_current_weather_for_city_id_should_return_weather_report
        result = provider.current_weather_for(OLOMOUC_ID)
        assert result.is_a?(Weather::Report)
        assert_equal OLOMOUC_NAME, result.city_name
        assert_equal OLOMOUC_ID, result.city_id
        assert result.temperature_in_celsius > -100
        assert result.temperature_in_fahrenheit > -100
        assert result.city_found?
      end

      def test_return_not_found_report_for_unknown_city_name
        result = provider.current_weather_for('Tarara-ringa Patamu')
        assert result.is_a?(Weather::Report)
        assert_equal 'Tarara-ringa Patamu', result.city_name
        assert_nil result.city_id
        assert_equal 0, result.temperature_in_celsius
        assert_equal 0, result.temperature_in_fahrenheit
        refute result.city_found?
      end
    end
  end
end
