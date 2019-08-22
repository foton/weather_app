# frozen_string_literal: true

module Weather
  class Report
    attr_reader :city, :city_id, :temperature_in_celsius, :temperature_in_fahrenheit

    def initialize(city:, city_id:, temperature_in_celsius: nil, temperature_in_fahrenheit: nil, not_found: false)
      @city = city
      @city_id = city_id
      @not_found = not_found

      if not_found
        @temperature_in_celsius = 0
        @temperature_in_fahrenheit = 0
      else
        calculate_temperatures(temperature_in_celsius, temperature_in_fahrenheit)
      end
    end

    def city_found?
      !@not_found
    end

    private

    def calculate_temperatures(temperature_in_celsius, temperature_in_fahrenheit)
      if temperature_in_celsius
        @temperature_in_celsius = temperature_in_celsius.to_f.round(2)
        @temperature_in_fahrenheit = ((temperature_in_celsius * 9 / 5) + 32).round(2)
      else
        @temperature_in_fahrenheit = temperature_in_fahrenheit.to_f
        @temperature_in_celsius = ((temperature_in_fahrenheit - 32) * 5 / 9).round(2)
      end
    end
  end
end
