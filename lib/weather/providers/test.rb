# frozen_string_literal: true

require_relative 'abstract.rb'

module Weather
  module Provider
    class Test < Weather::Provider::Abstract
      NOT_TO_BE_FOUND_CITY_NAME = 'not-to-be-found'
      TEST_TEMPERATURE_IN_CELSIUS = 21.21

      def initialize(*_args)
        super
        @test_time = :now
      end

      def current_weather_for(city_name_or_id)
        parse_city(city_name_or_id)
        return not_found_report if city_name == NOT_TO_BE_FOUND_CITY_NAME

        report_with(temperature_in_celsius: TEST_TEMPERATURE_IN_CELSIUS, time_in_utc: test_time)
      end

      def report_time_in_utc=(time)
        @test_time = time
      end

      private

      def test_time
        @test_time == :now ? Time.now.utc : @test_time.utc
      end
    end
  end
end
