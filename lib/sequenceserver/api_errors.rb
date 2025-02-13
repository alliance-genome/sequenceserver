module SequenceServer
  Error = Class.new(Sinatra::Error)

  # DatabaseUnreachableError is raised when the serialised Job object is
  # refering to a database that is not present in the current filesystem.
  class DatabaseUnreachableError < Error
    attr_reader :more_info

    def initialize(more_info)
      super
      @more_info = more_info
    end

    def title
      'Sequence database unreachable'
    end

    def message
      "The action you're trying to perform is not possible because \
        the database is unreachable. This can happen if the database has \
        been deleted or you are performing an action on an imported job."
    end
  end

  # API errors have an http status, title, message, and additional information
  # like stacktrace or information from program output.
  APIError = Class.new(Error)

  # Job not found (404).
  class NotFound < APIError
    def http_status
      404
    end

    def title
      'Job not found'
    end

    def message
      'The requested job could not be found'
    end

    def more_info
      ''
    end
  end

  # Errors caused due to incorrect user input.
  class InputError < APIError
    def initialize(more_info)
      @more_info = more_info
      super
    end

    def http_status
      400
    end

    def title
      'Input error'
    end

    def message
      <<~MSG
        Looks like there's a problem with one of the query sequences, selected
        databases, or advanced parameters. Details of the error are included
        below. Please ask on our
        <a href="https://github.com/wurmlab/sequenceserver/issues" target="_blank">issue tracker</a>
        or on our <a href="https://groups.google.com/g/sequenceserver">forum</a> if you are
        not sure what the error message means, or if the error message is just a number.
      MSG
    end

    attr_reader :more_info
  end

  # Errors caused by everything other than invalid user input.
  class SystemError < APIError
    def initialize(more_info = nil)
      @more_info = more_info || backtrace
      super
    end

    def http_status
      500
    end

    def title
      'System error'
    end

    def message
      <<~MSG
        Looks like there is a problem with the server. Try visiting the page again
        after a while. If this message persists, please report the problem on our
        <a href="https://github.com/wurmlab/sequenceserver/issues" target="_blank">
        issue tracker</a>.
      MSG
    end

    attr_reader :more_info
  end
end
