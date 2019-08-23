# frozen_string_literal: true

require 'minitest/autorun'
require 'pry-byebug'
require_relative '../../../lib/weather/storages/file.rb'
require_relative '../../../lib/weather/report.rb'

module Weather
  module Storage
    class TestFile < Minitest::Test
      attr_reader :storage, :report_params, :stored_columns

      def setup
        @report_params = { city_name: 'Olomouc,CZ', city_id: 3_069_011, temperature_in_celsius: 15.3 }
        @stored_columns = %i[city_name city_id temperature_in_celsius time_in_utc]
        @storage = Weather::Storage::File.new(filepath: 'weather_data_123456.json',
                                              stored_attributes: @stored_columns)

        @storage.clear!
      end

      def test_create_file_if_not_exists
        filename = 'new_storage.json'
        storage_params = { filepath: filename,
                           stored_attributes: stored_columns }
        ::File.delete(filename) if ::File.exist?(filename)

        refute ::File.file?(filename)

        storage = Weather::Storage::File.new(storage_params)
        assert ::File.file?(filename)
        assert storage.reports.size.zero?

        reports = build_reports(6)
        add_reports(reports, storage)
        assert_equal 6, storage.reports.size

        reopened_storage = Weather::Storage::File.new(storage_params)
        assert_equal 6, reopened_storage.reports.size

        ::File.delete(filename)
      end

      def test_if_stored_columns_are_changed_storage_is_cleared
        reports = build_reports(6)
        add_reports(reports, storage)

        assert_equal stored_columns, storage.stored_attributes

        reloaded_storage = Weather::Storage::File.new(filepath: storage.filepath,
                                                      stored_attributes: stored_columns)
        assert_equal 6, reloaded_storage.reports.size

        new_stored_columns = %i[city_id temperature_in_celsius]
        cleared_storage = Weather::Storage::File.new(filepath: storage.filepath,
                                                     stored_attributes: new_stored_columns)
        assert cleared_storage.reports.size.zero?
      end

      def test_get_reports_for_selected_city_name
        city_name1 = report_params[:city_name]
        reports = build_reports(5)
        add_reports(reports, storage)

        city_name2 = 'Praha'
        storage.add(Weather::Report.new(city_name: city_name2, city_id: 11, temperature_in_celsius: 15.3))

        assert_equal 5, storage.reports_for(city_name1).size
        assert_equal 1, storage.reports_for(city_name2).size
      end

      def test_get_reports_for_selected_city_id
        city_id1 = report_params[:city_id]
        reports = build_reports(5)
        add_reports(reports, storage)

        city_id2 = 123_456
        storage.add(Weather::Report.new(city_name: 'Praha', city_id: city_id2, temperature_in_celsius: 15.3))

        assert_equal 5, storage.reports_for(city_id1).size
        assert_equal 1, storage.reports_for(city_id2).size
      end

      private

      def build_reports(count)
        count.times.collect do |i|
          Weather::Report.new(report_params.merge(temperature_in_celsius: i + 10))
        end
      end

      def add_reports(reports, storage)
        reports.each { |report| storage.add(report) }
      end
    end
  end
end
