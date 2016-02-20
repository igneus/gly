module Gly
  # general application-specific error
  class Exception < StandardError
    def self.wrap(exception)
      e = new exception.message
      e.wrapped_exception = exception
      e
    end

    # may be nil
    attr_accessor :wrapped_exception
  end

  # error when parsing gly input file
  class ParseError < Exception; end
end
