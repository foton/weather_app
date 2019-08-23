# frozen_string_literal: true

require 'json'
require 'time'
require_relative './abstract.rb'

module Weather
  module Storage
    class File < Weather::Storage::Abstract
      attr_reader :filepath

      def initialize(stored_attributes:, filepath:)
        super(stored_attributes: stored_attributes)
        @filepath = filepath

        check_file
      end

      private

      attr_reader :stored_keys

      def check_file
        if ::File.file?(filepath)
          clear! if stored_attributes_changed?
        else
          create_new_file
        end
      end

      def stored_attributes_changed?
        return false if reports.empty?

        stored_keys.sort != stored_attributes.sort
      end

      def create_new_file
        clear!
      end

      def save!
        ::File.write(filepath, JSON.pretty_generate(record_hashes))
      end

      def load_reports
        build_reports_from(stored_records)
      end

      def record_hashes
        reports.collect { |report| build_record_from(report) }
      end

      def build_record_from(report)
        stored_attributes.each_with_object({}) do |key, hash|
          hash[key.to_sym] = report.send(key)
        end
      end

      def build_reports_from(stored_records)
        stored_records.collect { |json_hash| build_report_from(json_hash) }
      end

      def stored_records
        stored_records = symbolize_keys(JSON.parse(::File.read(filepath)))
        @stored_keys = stored_records.first&.keys
        stored_records
      end

      def symbolize_keys(json_records)
        json_records.collect do |rec|
          rec.keys.each_with_object({}) do |key, hash|
            hash[key.to_sym] = rec[key]
          end
        end
      end

      def build_report_from(json_hash)
        json_hash[:time_in_utc] = Time.parse(json_hash[:time_in_utc]).utc if json_hash[:time_in_utc].is_a?(String)
        Weather::Report.new(json_hash)
      end
    end
  end
end
