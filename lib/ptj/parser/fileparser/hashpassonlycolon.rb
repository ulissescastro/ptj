module PTJ
  module Parser
    # FileParser class which allows you to parse a file line by line.
    #
    class HashPassOnlyColon < FileParser

      # Expecting the following format:
      # hash:pass
      # hash:pass
      # hash:pass
      #
      # @param line
      #   Individual line from a text file
      #
      # @return Hash Password, Password Hash
      def parse_line(line)
        if line =~ /^(\S+):(\S+)/
          pass = $~[2]
          hash = $~[1]
        end
        {:mypass => pass, :myhash => hash}
      end

    end
  end
end
