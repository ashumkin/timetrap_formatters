module Timetrap
  module Formatters
    class Timetrap::Formatters::Datesheet
      attr_accessor :output
      include Timetrap::Helpers

      def time_format
        "%Y-%m-%d"
      end

      def initialize entries
        self.output = ''
        by_date = entries.inject({}) do |h, e|
          date = e.start.to_date
          h[date] ||= []
          h[date] << e
          h
        end

        by_date.keys.sort.each do |date|
          by_date[date].each_with_index do |e, i|
            self.output <<  "%3s %10s%11s -%9s%10s  [%s]  %s\n" % [
              (Timetrap::CLI.args['-v'] ? e.id : ''),
              e.start.strftime(time_format),
              format_time(e.start),
              format_time(e.end),
              format_duration(e.duration),
              e.sheet,
              e.note
            ]
          end
        end
      end
    end
  end
end
