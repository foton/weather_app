# frozen_string_literal: true
require_relative 'abstract.rb'
module Weather
  module Provider
    class Test < Weather::Provider::Abstract

      def initialize(*args)
        @city_name = 'Unknown'
        @city_id = nil
      end

      def current_weather_for(city_name_or_id)
        parse_city(city_name_or_id)

        Weather::Report.new(city: city_name, city_id: city_id, temperature_in_celsius: 21.21)
      end

      private

      attr_reader :city_name, :city_id

      def parse_city(city_name_or_id)
        if /\A\d+\z/.match(city_name_or_id.to_s)
          @city_id = city_name_or_id.to_i
        else
          @city_name = city_name_or_id.to_s
        end
      end
    end
  end
end
