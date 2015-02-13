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

        id_heading = Timetrap::CLI.args['-v'] ? 'Id ' : ''
        longest_sheet = entries.inject('Sheet'.length) {|l, e| [e.sheet.rstrip.length, l].max}
        longest_note = entries.inject('Notes'.length) {|l, e| [e.note.rstrip.length, l].max}

        by_date.keys.sort.each do |date|
          self.output << "## #{format_date date} ##\n\n"

          self.output << "                 Notes  Duration\n" % (' '*(longest_sheet-5))

          last_sheet = nil

          by_date[date].group_by(&:note).each do |k, v|
            duration = v.map(&:duration).reduce(:+)
            line     = v.first

            self.output <<  "%-4s - %15s %s\n" % [
              (Timetrap::CLI.args['-v'] ? line.id : ''),
              line.note,
              format_duration(duration),
            ]
          end

          self.output << "    %s\n" % ('─'*(40+longest_sheet + longest_note))
          self.output << "    Total%43s\n" % format_total(by_date[date])
          self.output << "\n"

        end

        if by_date.size > 1
          self.output <<  "%s\n" % ('─'*(4+40+longest_sheet + longest_note))
          self.output <<  "Grand Total%41s\n" % format_total(by_date.values.flatten)
        end
      end
    end
  end
end
