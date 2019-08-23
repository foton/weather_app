# frozen_string_literal: true

require_relative '../report.rb'

module Weather
  module Provider
    class Abstract
      def initialize(*_args)
        @city_name = 'Unknown'
        @city_id = nil
      end

      def current_weather_for(_city_name_or_id)
        raise NotImplementedError, "#{self.class.name}#current_weather_for() is an abstract method."
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

      def not_found_report
        report = report_with({})
        report.not_found!
        report
      end

      def report_with(attributes = {})
        base_atts = { city_name: city_name,
                      city_id: city_id,
                      temperature_in_celsius: nil,
                      time_in_utc: Time.now.utc }
        Weather::Report.new(base_atts.merge(attributes))
      end
    end
  end
end
