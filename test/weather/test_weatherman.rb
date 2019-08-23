# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/weather/weatherman.rb'
require_relative '../../lib/weather/storages/file.rb'
require_relative '../../lib/weather/providers/test.rb'

module Weather
  class TestWeatherman < Minitest::Test
    attr_reader :provider, :storage, :weatherman, :test_temperature, :city_name

    def setup
      @provider = Weather::Provider::Test.new
      stored_columns = %i[city_name city_id temperature_in_celsius time_in_utc]
      @storage = Weather::Storage::File.new(filepath: 'weather_data_123456.json',
                                            stored_attributes: stored_columns)
      @storage.clear!

      @weatherman = Weather::Weatherman.new(provider, storage)
      @city_name = 'Olomouc'
      @test_temperature = Weather::Provider::Test::TEST_TEMPERATURE_IN_CELSIUS
    end

    def test_initialize_with_provider_and_store
      assert_equal provider, weatherman.provider
      assert_equal storage, weatherman.storage
    end

    def test_grabs_current_weather_for_city_by_name
      assert storage.reports.size.zero?

      report = weatherman.current_weather_for(city_name)

      assert_equal 1, storage.reports.size

      assert_equal city_name, report.city_name
      assert_equal test_temperature, report.temperature_in_celsius
    end

    def test_grabs_current_weather_for_city_by_id
      assert storage.reports.size.zero?

      report = weatherman.current_weather_for(123)

      assert_equal 1, storage.reports.size

      assert_equal 'Unknown', report.city_name
      assert_equal 123, report.city_id
      assert_equal test_temperature, report.temperature_in_celsius
    end

    def test_produces_average_report_for_city
      temperatures = [10, 11.8, 12.1, 13.3, 14]
      avg_temp_c, avg_temp_f = expected_average_temperatures_for(temperatures)
      reports = build_reports(temperatures)

      avg_temp_hash = storage.stub(:reports, reports) do
        weatherman.average_temperature_for(city_name)
      end

      assert_equal city_name, avg_temp_hash[:city_name]
      assert_equal avg_temp_c, avg_temp_hash[:in_celsius]
      assert_equal avg_temp_f, avg_temp_hash[:in_fahrenheit]

      assert_equal reports[0].time_in_utc, avg_temp_hash[:from_time]
      assert_equal reports[-1].time_in_utc, avg_temp_hash[:to_time]
    end

    def test_produces_average_report_for_time_interval
      temperatures = [10, 11.8, 12.1, 13.3, 14]
      avg_temp_c, avg_temp_f = expected_average_temperatures_for(temperatures[2..-1])
      times = Array.new(temperatures.size) { |i| Time.new(2019, 8, 8, 2, (2 + i), 2, '+00:00') }

      reports = build_reports(temperatures, times)

      avg_temp_for_period = storage.stub(:reports, reports) do
        weatherman.average_temperature_for(city_name,
                                           from_time: (times[2] - 10), # -10 seconds
                                           to_time: (times[-1] + 5))
      end

      assert_equal city_name, avg_temp_for_period[:city_name]
      assert_equal avg_temp_c, avg_temp_for_period[:in_celsius]
      assert_equal avg_temp_f, avg_temp_for_period[:in_fahrenheit]
      assert_equal reports[2].time_in_utc, avg_temp_for_period[:from_time]
      assert_equal reports[-1].time_in_utc, avg_temp_for_period[:to_time]
    end

    def test_if_no_reports_founded_returns_no_report_average_result
      time1 = Time.new(2019, 8, 1)
      time2 = Time.new(2019, 8, 6)
      avg_temp = storage.stub(:reports, []) do
        weatherman.average_temperature_for(city_name, from_time: time1, to_time: time2)
      end

      assert_equal city_name, avg_temp[:city_name]
      assert_equal :no_data, avg_temp[:in_celsius]
      assert_equal :no_data, avg_temp[:in_fahrenheit]
      assert_equal time1, avg_temp[:from_time]
      assert_equal time2, avg_temp[:to_time]
    end

    private

    def build_reports(temperatures, times = nil)
      times = Array.new(temperatures.size) { |_i| Time.now.utc } if times.nil?

      temperatures.each_with_index.collect do |temperature, i|
        Weather::Report.new(city_name: city_name,
                            city_id: 3_069_011,
                            temperature_in_celsius: temperature,
                            time_in_utc: times[i])
      end
    end

    def expected_average_temperatures_for(temperatures)
      temp_c = (temperatures.sum.to_f / temperatures.size)
      temp_f = ((temperatures.collect { |tc| ((tc * 9 / 5) + 32).round(2) }).sum.to_f / temperatures.size)
      [temp_c, temp_f]
    end
  end
end
