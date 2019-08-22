# frozen_string_literal: true

require_relative 'abstract.rb'

module Weather
  module Provider
    class Test < Weather::Provider::Abstract
      NOT_TO_BE_FOUND_CITY_NAME = 'not-to-be-found'
      def current_weather_for(city_name_or_id)
        parse_city(city_name_or_id)
        return not_found_report if city_name == NOT_TO_BE_FOUND_CITY_NAME

        Weather::Report.new(city: city_name, city_id: city_id, temperature_in_celsius: 21.21)
      end
    end
  end
end
