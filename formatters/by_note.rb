# encoding: UTF-8
module Timetrap
  module Formatters
    class ByNote
      attr_accessor :output
      include Timetrap::Helpers

      def initialize entries
        self.output = ''

        by_date = entries.inject({}) do |h, e|
          date = e.start.to_date
          h[date] ||= []
          h[date] << e
          h
        end

        id_heading = Timetrap::CLI.args['-v'] ? 'Id' : ''
        longest_note = entries.inject('Notes'.length) {|l, e| [e.note.rstrip.length, l].max}

        dash_len = 'Duration - '.length
        by_date.keys.sort.each do |date|
          self.output << "## #{format_date date} ##\n\n"

          self.output << "%3s Duration   Notes\n" % id_heading

          by_date[date].group_by(&:note).each do |k, v|
            duration = v.map(&:duration).reduce(:+)
            line     = v.first

            self.output <<  "%3s %8s - %-15s\n" % [
              (Timetrap::CLI.args['-v'] ? line.id : ''),
              format_duration(duration),
              line.note,
            ]
          end

          self.output << "    %s\n" % ('─' * (dash_len + longest_note))
          self.output << "    Total: %12s\n" % format_total(by_date[date])
          self.output << "\n"

        end

        if by_date.size > 1
          self.output <<  "%s\n" % ('─' * ('##  '.length + dash_len + longest_note))
          self.output <<  "Grand Total: %10s\n" % format_total(by_date.values.flatten)
        end
      end
    end
  end
end
