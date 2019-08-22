# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/weather/storages/file.rb'
require_relative '../../../lib/weather/report.rb'

module Weather
  module Storage
    class TestFile < Minitest::Test
      attr_reader :storage, :report_params, :stored_records_count, :stored_columns

      def setup
        @stored_records_count = 5
        @report_params = { city: 'Olomouc,CZ', city_id: 3_069_011, temperature_in_celsius: 15.3 }
        @stored_columns = %i[city city_id temperature_in_celsius]
        @storage = Weather::Storage::File.new(filepath: 'weather_data_123456.json',
                                              stored_attributes: @stored_columns,
                                              stored_records_count: stored_records_count)
      end

      def test_create_file_if_not_exists
        filename = 'new_storage.json'
        storage_params = { filepath: filename,
                           stored_attributes: stored_columns,
                           stored_records_count: stored_records_count }
        ::File.delete(filename) if ::File.exist?(filename)

        refute ::File.file?(filename)

        storage = Weather::Storage::File.new(storage_params)
        assert ::File.file?(filename)
        assert storage.reports.size.zero?

        reports = build_reports(stored_records_count + 1)
        add_reports(reports, storage)
        assert_equal stored_records_count, storage.reports.size

        reopened_storage = Weather::Storage::File.new(storage_params)
        assert_equal stored_records_count, reopened_storage.reports.size

        ::File.delete(filename)
      end

      def test_stores_required_number_of_records
        storage.clear!
        reports = build_reports(stored_records_count + 1)

        stored_records_count.times do |i|
          storage.add(reports[i])
          assert_equal i + 1, storage.reports.size
        end
        assert_equal reports.first, storage.reports.first
        assert_equal reports[stored_records_count - 1], storage.reports.last

        storage.add(reports[stored_records_count])

        assert_equal reports[1], storage.reports.first
        assert_equal reports[stored_records_count], storage.reports.last
      end

      def test_if_stored_columns_are_changed_storage_is_cleared
        reports = build_reports(stored_records_count + 1)
        add_reports(reports, storage)

        assert_equal stored_records_count, storage.reports.size
        assert_equal stored_columns, storage.stored_attributes

        reloaded_storage = Weather::Storage::File.new(filepath: storage.filepath,
                                                      stored_attributes: stored_columns,
                                                      stored_records_count: stored_records_count)
        assert_equal stored_records_count, reloaded_storage.reports.size

        new_stored_columns = %i[city_id temperature_in_celsius]
        cleared_storage = Weather::Storage::File.new(filepath: storage.filepath,
                                                     stored_attributes: new_stored_columns,
                                                     stored_records_count: stored_records_count)
        assert cleared_storage.reports.size.zero?
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
