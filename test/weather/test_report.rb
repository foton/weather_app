# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/weather/report.rb'

module Weather
  class TestReport < Minitest::Test
    def setup
      time = Time.now.utc
      @attributes = { city_name: 'Olomouc,cs',
                      city_id: 3_069_011,
                      temperature_in_celsius: 15.3,
                      temperature_in_fahrenheit: nil,
                      time_in_utc: time }
    end

    def test_initialization
      report = Weather::Report.new(@attributes)

      assert_equal @attributes[:city_name], report.city_name
      assert_equal @attributes[:city_id], report.city_id
      assert_equal @attributes[:temperature_in_celsius], report.temperature_in_celsius
      assert_equal 59.54, report.temperature_in_fahrenheit
      assert_equal @attributes[:time_in_utc], report.time_in_utc
      assert report.city_found?
    end

    def test_conversion_to_fahrenheit
      report = Weather::Report.new(@attributes)

      assert_equal 15.3, report.temperature_in_celsius
      assert_equal 59.54, report.temperature_in_fahrenheit
    end

    def test_conversion_to_celsius
      report = Weather::Report.new(@attributes.merge(temperature_in_celsius: nil,
                                                     temperature_in_fahrenheit: 71.42))

      assert_equal 71.42, report.temperature_in_fahrenheit
      assert_equal 21.9, report.temperature_in_celsius
    end

    def test_not_found_report
      report = Weather::Report.new(@attributes)
      assert_equal @attributes[:city_name], report.city_name
      assert_equal @attributes[:city_id], report.city_id
      assert_equal @attributes[:time_in_utc], report.time_in_utc
      assert_equal 15.3, report.temperature_in_celsius
      assert_equal 59.54, report.temperature_in_fahrenheit
      assert report.city_found?

      report.not_found!

      assert_equal @attributes[:city_name], report.city_name
      assert_equal @attributes[:city_id], report.city_id
      assert_equal @attributes[:time_in_utc], report.time_in_utc
      assert_equal 0, report.temperature_in_celsius
      assert_equal 0, report.temperature_in_fahrenheit
      refute report.city_found?
    end

    def test_it_can_be_compared
      time = Time.now.utc
      first = Weather::Report.new(city_name: 'Olomouc,cs',
                                  city_id: 1,
                                  temperature_in_celsius: 7,
                                  time_in_utc: time)
      second = Weather::Report.new(city_name: 'A',
                                    city_id: 3_069_011,
                                    temperature_in_celsius: 5,
                                    time_in_utc: time)
      third = Weather::Report.new(city_name: 'Olomouc,cs',
                                  city_id: 3_069_011,
                                  temperature_in_celsius: 3,
                                  time_in_utc: time)
      fourth = Weather::Report.new(city_name: 'Olomouc,cs',
                                   city_id: 3_069_011,
                                   temperature_in_celsius: 7,
                                   time_in_utc: time + 1)
      fifth = Weather::Report.new(city_name: 'Olomouc,cs',
                                  city_id: 3_069_011,
                                  temperature_in_celsius: 7,
                                  time_in_utc: time + 1)

      assert_equal [first, second, third, fourth, fifth], [third, second, fourth, fifth, first].sort
    end
  end
end
