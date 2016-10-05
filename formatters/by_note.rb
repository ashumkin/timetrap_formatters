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
        separator = Timetrap::Config['by_note_separator']
        re_match = separator ? Regexp.new(separator) : /.+/
        by_date.keys.sort.each do |date|
          self.output << "## #{format_date date} ##\n\n"

          self.output << "%3s Duration   Notes\n" % id_heading

          by_date_hash = by_date[date].group_by do |item|
            note = item[:note]
            if matches = re_match.match(note)
              note = matches[0]
              item[:note_part] = matches.post_match
            end
            note
          end

          if ENV['DEBUG'] && ENV['DEBUG'] != '0'
            require 'pp'
            pp by_date_hash
          end

          by_date_hash.each do |k, v|
            duration = v.map(&:duration).reduce(:+)

            formatted_duration = format_duration(duration)
            notes_used = []
            note = nil
            v.each do |line|
              note = line[:note]
              unless notes_used.include?(note)
                self.output <<  "%3s %8s - %-15s\n" % [
                  (Timetrap::CLI.args['-v'] ? line.id : ''),
                  formatted_duration,
                  note,
                ]
                notes_used << note
              end
              note = nil
              formatted_duration = ''
            end
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
