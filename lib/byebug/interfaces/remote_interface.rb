require 'byebug/history'

module Byebug
  #
  # Interface class for remote use of byebug.
  #
  class RemoteInterface < Interface
    def initialize(socket)
      super()
      @input, @output, @error = socket, socket, socket
    end

    def read_command(prompt)
      super("PROMPT #{prompt}")
    end

    def confirm(prompt)
      super("CONFIRM #{prompt}")
    end

    def close
      output.close
    rescue IOError
      errmsg('Error closing the interface...')
    end

    def readline(prompt, hist)
      output.puts(prompt)

      result = input.gets
      fail IOError unless result

      @history.push(result) if hist

      result.chomp
    end
  end
end
