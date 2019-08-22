# frozen_string_literal: true

module Weather
  module Provider
    class Abstract
      def initialize(*args)
        raise NotImplementedError.new("#{self.class.name} is an abstract class.")
      end

      def current_weather_for(_city_name_or_id)
        raise NotImplementedError.new("#{self.class.name}#current_weather_for() is an abstract method.")
      end
    end
  end
end
