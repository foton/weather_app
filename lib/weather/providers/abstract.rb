# frozen_string_literal: true

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
        Weather::Report.new(city: city_name, city_id: city_id, not_found: true)
      end
    end
  end
end
