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

      def total_count(line)
        raise(NotImplementedError, "This is an abstract implementation, you must override parse_line")
      end
    end
  end
end

require 'ptj/parser/fileparser/passhashonly'
require 'ptj/parser/fileparser/passonly'
require 'ptj/parser/fileparser/hashpassonlycolon'
require 'ptj/parser/fileparser/countpassonly'
require 'ptj/parser/fileparser/passthreecolons'
