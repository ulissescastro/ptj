module PTJ
  module Parser
    # FileParser class which allows you to parse a file line by line.
    #
    class PassHashOnly < FileParser

      # Expecting the following format:
      # pass, hash
      # pass, hash
      # pass, hash
      #
      # @param line
      #   Individual line from a text file
      #
      # @return Hash Password, Password Hash
      def parse_line(line)
        if line =~ /^(\S+),\s(\S+)/
          pass = $~[1]
          hash = $~[2]
        end
        {:mypass => pass, :myhash => hash}
      end

      # Method used to return the total number of passwords that will be added
      # to PTJ
      #
      # @param file
      #   File path which will be read
      #
      # @return Integer
      #
      def total_count(file)
        file_obj = File.new(file,'r')
        file_obj.readlines.size
      end

    end
  end
end
