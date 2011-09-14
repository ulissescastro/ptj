module PTJ
  module Parser
    class FileParser

      # Parse a file line-by-line and return the necessary results.
      #
      # @param line
      #   Individual line of the file.
      #
      # @return Hash 
      #   :mypass => value, :myhash => value, :count => value (optional)
      def parse_line(line)
        raise(NotImplementedError, "This is an abstract implementation, you must override parse_line")
      end

      def total_count(file)
        file_obj = File.new(file,'r')
        lines = file_obj.readlines 
        counter = 0
        lines.each do |line|
          line = line.force_encoding("BINARY")
          return_hash = self.parse_line(line)
          if return_hash.has_key?(:count)
            counter = counter + return_hash[:count].to_i
          else
            counter = counter + 1
          end
        end
        counter
      end
    end
  end
end

require 'ptj/parser/fileparser/passhashonly'
require 'ptj/parser/fileparser/passonly'
require 'ptj/parser/fileparser/hashpassonlycolon'
require 'ptj/parser/fileparser/countpassonly'
require 'ptj/parser/fileparser/passthreecolons'
