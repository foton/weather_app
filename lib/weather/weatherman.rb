# frozen_string_literal: true

module Weather
  class Weatherman
    attr_reader :provider, :storage

    def initialize(provider, storage)
      @provider = provider
      @storage = storage
    end

    def current_weather_for(city_name_or_id)
      report = provider.current_weather_for(city_name_or_id)
      storage.add(report)
      report
    end

    def average_temperature_for(city_name_or_id, from_time: nil, to_time: nil)
      current_weather_for(city_name_or_id) if storage.reports.size.zero?

      reports = reports_for_city_and_time_period(city_name_or_id, from_time, to_time).sort_by(&:time_in_utc)

      return no_reports_hash_for(city_name_or_id, from_time, to_time) if reports.empty?

      { city_name: reports.first.city_name,
        in_celsius: (reports.sum(&:temperature_in_celsius) / reports.size).round(2),
        in_fahrenheit: (reports.sum(&:temperature_in_fahrenheit) / reports.size).round(2),
        from_time: reports.first.time_in_utc,
        to_time: reports.last.time_in_utc }
    end

    private

    def reports_for_city_and_time_period(city_name_or_id, from_time, to_time)
      reports = storage.reports_for(city_name_or_id).uniq(&:time_in_utc)
      return reports if from_time.nil? || to_time.nil?

      reports.select { |r| (from_time.utc..to_time).cover?(r.time_in_utc) }
    end

    def no_reports_hash_for(city_name_or_id, from_time, to_time)
      {
        city_name: city_name_or_id,
        in_celsius: :no_data,
        in_fahrenheit: :no_data,
        from_time: from_time,
        to_time: to_time
      }
    end
  end
end
