# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/weather/providers/test.rb'

module Weather
  module Provider
    class TestTestProvider < Minitest::Test
      attr_reader :provider

      def setup
        @provider = Weather::Provider::Test.new
      end

      def test_current_weather_for_city_name_should_return_weather_report
        result = provider.current_weather_for('Olomouc')
        assert result.is_a?(Weather::Report)
        assert_equal 'Olomouc', result.city
        assert_nil result.city_id
        assert_equal 21.21, result.temperature_in_celsius
        assert_equal 70.18, result.temperature_in_fahrenheit
        assert result.city_found?
      end

      def test_current_weather_for_city_id_should_return_weather_report
        result = provider.current_weather_for(123_456)
        assert result.is_a?(Weather::Report)
        assert_equal 'Unknown', result.city
        assert_equal 123_456, result.city_id
        assert_equal 21.21, result.temperature_in_celsius
        assert_equal 70.18, result.temperature_in_fahrenheit
        assert result.city_found?
      end

      def test_return_same_temperatures_for_different_cities
        result = provider.current_weather_for('Tarara-ringa Patamu')
        assert result.is_a?(Weather::Report)
        assert_equal 'Tarara-ringa Patamu', result.city
        assert_nil result.city_id
        assert_equal 21.21, result.temperature_in_celsius
        assert_equal 70.18, result.temperature_in_fahrenheit
        assert result.city_found?
      end

      def test_return_not_found_city_for_special_city_name
        result = provider.current_weather_for(Weather::Provider::Test::NOT_TO_BE_FOUND_CITY_NAME)
        assert result.is_a?(Weather::Report)
        assert_equal Weather::Provider::Test::NOT_TO_BE_FOUND_CITY_NAME, result.city
        assert_nil result.city_id
        assert_equal 0, result.temperature_in_celsius
        assert_equal 0, result.temperature_in_fahrenheit
        refute result.city_found?
      end
    end
  end
end
