require 'forwardable'

module Gly
  class Headers
    extend Forwardable

    # header fields supported by gregorio.
    # Based on http://gregorio-project.github.io/gabc/index.html#header
    # last checked 2015-12-06
    GREGORIO_HEADERS = %w(
name
gabc-copyright
score-copyright
office-part
occasion
meter
commentary
arranger
gabc-version
author
date
manuscript
manuscript-reference
manuscript-storage-place
book
transcriber
transcription-date
gregoriotex-font
mode
initial-style
centering-scheme
user-notes
annotation
)

    def initialize
      # for quick lookup. Only holds a single value per header
      @headers = {}
      # holds order and as many values for a header as given in the
      # score (typically annotation occurs more than once)
      @pairs = []
    end

    def []=(key, value)
      @headers[key] = value
      @pairs << [key, value]
    end

    def_delegator :@headers, :[]

    def each_pair
      @pairs.each do |k|
        yield k[0], k[1]
      end
    end

    def self.gregorio_supported?(key)
      GREGORIO_HEADERS.include? key
    end
  end
end
