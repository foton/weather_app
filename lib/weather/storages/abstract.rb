# frozen_string_literal: true

require_relative '../report.rb'

module Weather
  module Storage
    class Abstract
      attr_reader :stored_attributes

      def initialize(stored_attributes:)
        @stored_attributes = stored_attributes
      end

      def clear!
        @reports = []
        save!
      end

      def add(report)
        reports << report
        save!
      end

      def reports
        @reports ||= load_reports
      end

      def reports_for(city_name_or_id)
        reports.select { |report| [report.city_name, report.city_id].include?(city_name_or_id) }
      end

      private

      def save!
        raise NotImplementedError, "#{self.class.name}#save! is an abstract method."
      end

      def load_reports
        raise NotImplementedError, "#{self.class.name}#load_reports is an abstract method."
      end

    end
  end
end
