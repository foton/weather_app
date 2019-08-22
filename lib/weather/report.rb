module Weather
  class Report
    attr_reader :city, :city_id, :temperature_in_celsius, :temperature_in_fahrenheit

    def initialize(city:, city_id:, temperature_in_celsius: nil, temperature_in_fahrenheit: nil)
      @city = city
      @city_id = city_id

      if temperature_in_celsius
        @temperature_in_celsius = temperature_in_celsius.to_f.round(2)
        @temperature_in_fahrenheit = ((temperature_in_celsius * 9/5) + 32).round(2)
      else
        @temperature_in_fahrenheit = temperature_in_fahrenheit.to_f
        @temperature_in_celsius = ((temperature_in_fahrenheit - 32 ) * 5/9).round(2)
      end
    end
  end
end
