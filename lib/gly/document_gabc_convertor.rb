module Gly
  class DocumentGabcConvertor
    def initialize(document, options={})
      @doc = document
      @options = options
      @output_name_base = @options[:output_file] || File.basename(@doc.path)
    end

    def convert
      each_score_with_gabcname do |score, out_fname|
        if @output_name_base == '-'
          convert_to STDOUT, score
        else
          File.open(out_fname, 'w') do |fw|
            convert_to fw, score
          end
        end
        yield score, out_fname if block_given?
      end
    end

    # iterates over document scores,
    # yields score and filename of it's generated gabc file
    def each_score_with_gabcname
      return to_enum(:each_score_with_gabcname) unless block_given?

      @doc.scores.each_with_index do |score, si|
        gabc = gabc_fname(score, si)
        gtex = gtex_fname(score, si)
        yield score, gabc, gtex
      end
    end

    private

    def convert_to(io, score)
      GabcConvertor.new.convert score, io
    end

    def gabc_fname(score, score_index=nil)
      if @doc.scores.size == 1 && !@options[:suffix_always]
        score_id = ''
      else
        score_id = '_' + (score.headers['id'] || score_index.to_s)
      end

      @output_name_base
        .sub(/(\.(gly|gabc))?\Z/i, "#{score_id}.gabc")
    end

    def gtex_fname(score, score_index=nil)
      gabc_fname(score, score_index).sub('.gabc', '.gtex')
    end
  end
end
