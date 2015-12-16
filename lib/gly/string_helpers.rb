module Gly
  module StringHelpers
    extend self

    # splits string by whitespace that is not enclosed
    # in brackets.
    # At the same time removes brackets.
    def bracket_aware_whitespace_split(str)
      str = str.strip
      chunk_start = 0
      chunks = []
      in_brackets = false
      str.chars.each_with_index do |char, chi|
        if in_brackets
          if char == ')'
            in_brackets = false
            chunks << str[chunk_start .. chi-1]
            chunk_start = chi + 1
          end
        else
          if char == '('
            in_brackets = true
            chunk_start = chi + 1
          elsif char =~ /^\s$/
            if chunk_start != chi
              chunks << str[chunk_start .. chi-1]
            end
            chunk_start = chi+1
          end
        end
      end

      if chunk_start < str.size
        chunks << str[chunk_start .. -1]
      end

      chunks
    end

    alias_method :music_split, :bracket_aware_whitespace_split
  end
end
