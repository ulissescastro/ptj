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
        ret_ary = []
        count.to_i.times do 
          ret_ary << {:mypass => pass, :myhash => hash}
        end
        ret_ary
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
        counter = 0
        while (line = file_obj.gets)
          line = line.force_encoding("BINARY")
          if line =~ /^\s*(\d+)\s*(\S+)\s*$/
            counter += $~[1].to_i 
          end
        end
        counter
      end

    end
  end
end
