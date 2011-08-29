module PTJ
  module Parser
    # FileParser class which allows you to parse a file line by line.
    #
    class PassThreeColons < FileParser

      # Expecting the following format:
      # something ::: pass ::: something
      # something ::: pass ::: something
      # something ::: pass ::: something
      #
      # @param line
      #   Individual line from a text file
      #
      # @return Hash Password, Password Hash
      def parse_line(line)
        if line =~ /\s*\S*\s*:::\s*(\S+)\s*:::/
          pass = $~[1]
          hash = nil
        end
        {:mypass => pass, :myhash => hash}
      end

    end
  end
end
