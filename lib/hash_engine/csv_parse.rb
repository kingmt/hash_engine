# Code based on FasterCSV 
#  Created by James Edward Gray II on 2005-10-31.
#  Copyright 2005 Gray Productions. All rights reserved.
#
# This is a cut down and simplified version for dealing with a single line

module HashEngine
  module CSVParse

    QUOTE_CHAR = '"'.freeze
    DEFAULT_DELIMITER = ','.freeze
    QUOTED_FIELD = Regexp.new /^"(.*)"$/

    def parse_line(line, headers, delimiter=DEFAULT_DELIMITER)
      delimiter = DEFAULT_DELIMITER if delimiter.empty?
      result = {:error => []}
      unless line.empty?
        parse = line.chomp
        csv           = Array.new
        current_field = String.new
        field_quotes  = 0
        parse.split(delimiter, -1).each do |match|
          if current_field.empty? && match.count(QUOTE_CHAR).zero?
            csv           << (match.empty? ? nil : match)
          else
            current_field << match
            field_quotes += match.count(QUOTE_CHAR)
            if field_quotes % 2 == 0
              in_quotes = current_field[QUOTED_FIELD, 1] || current_field
              current_field = in_quotes
              current_field.gsub!(QUOTE_CHAR * 2, QUOTE_CHAR) # unescape contents
              csv           << current_field
              current_field =  String.new
              field_quotes  =  0
            else # we found a quoted field that spans multiple lines
              current_field << delimiter
            end
          end
        end
        if csv.size == headers.size
          headers.each_with_index {|name, index| result[name] = csv[index] }
        else
          result[:error] = ["header.size: #{headers.size} parsed_data.size: #{csv.size}"]
        end
      end
      result
    end
  end
end
