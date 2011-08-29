module PTJ
  module Parser
    # FileParser class which allows you to parse a file line by line.
    #
    class CountPassOnly < FileParser

      # Expecting the following format:
      # pass, hash
      # pass, hash
      # pass, hash
      #
      # @param line
      #   Individual line from a text file
      #
      # @return Hash Password, Password Hash, Count
      def parse_line(line)
        if line =~ /^\s*(\d+)\s*(\S+)\s*$/
          count = $~[1]
          pass = $~[2]
          hash = nil
        end
        {:mypass => pass, :myhash => hash, :count => count}
      end

    end
  end
end
