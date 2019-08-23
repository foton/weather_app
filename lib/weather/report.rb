# frozen_string_literal: true

module Weather
  class Report
    ATTRIBUTES = %i[city_name city_id temperature_in_celsius temperature_in_fahrenheit time_in_utc].freeze
    attr_reader(*ATTRIBUTES)

    def initialize(attributes)
      @not_found = false
      ATTRIBUTES.each { |att| instance_variable_set("@#{att}", attributes[att]) }

      calculate_temperatures(temperature_in_celsius, temperature_in_fahrenheit)
    end

    def not_found!
      @not_found = true
      @temperature_in_celsius = 0
      @temperature_in_fahrenheit = 0
    end

    def city_found?
      !@not_found
    end

    def <=>(other)
      by_id = city_id <=> other.city_id
      return by_id unless by_id.zero?

      by_name = city_name <=> other.city_name
      return by_name unless by_name.zero?

      time_in_utc <=> other.time_in_utc
    end

    private

    def calculate_temperatures(temperature_in_celsius, temperature_in_fahrenheit)
      if temperature_in_celsius
        @temperature_in_celsius = temperature_in_celsius.to_f.round(2)
        @temperature_in_fahrenheit = ((temperature_in_celsius * 9 / 5) + 32).round(2)
      elsif temperature_in_fahrenheit
        @temperature_in_fahrenheit = temperature_in_fahrenheit.to_f
        @temperature_in_celsius = ((temperature_in_fahrenheit - 32) * 5 / 9).round(2)
      end
    end
  end
end
