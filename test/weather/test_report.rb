# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/weather/report.rb'

module Weather
  class TestReport < Minitest::Test
    def setup
      @attributes = { city: 'Olomouc,cs',
                      city_id: 3_069_011,
                      temperature_in_celsius: 15.3,
                      temperature_in_fahrenheit: nil }
    end

    def test_initialization
      report = Weather::Report.new(@attributes)
      assert_equal @attributes[:city], report.city
      assert_equal @attributes[:city_id], report.city_id
      assert_equal @attributes[:temperature_in_celsius], report.temperature_in_celsius
      assert_equal 59.54, report.temperature_in_fahrenheit
      assert report.city_found?
    end

    def test_conversion_to_fahrenheit
      report = Weather::Report.new(@attributes)

      assert_equal 15.3, report.temperature_in_celsius
      assert_equal 59.54, report.temperature_in_fahrenheit
      assert report.city_found?
    end

    def test_conversion_to_celsius
      report = Weather::Report.new(@attributes.merge(temperature_in_celsius: nil,
                                                     temperature_in_fahrenheit: 71.42))

      assert_equal 71.42, report.temperature_in_fahrenheit
      assert_equal 21.9, report.temperature_in_celsius
      assert report.city_found?
    end

    def test_setup_not_found_report
      report = Weather::Report.new(@attributes.merge(not_found: true))

      assert_equal @attributes[:city], report.city
      assert_equal @attributes[:city_id], report.city_id
      assert_equal 0, report.temperature_in_celsius
      assert_equal 0, report.temperature_in_fahrenheit
      refute report.city_found?
    end
  end
end
