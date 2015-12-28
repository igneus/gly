module Gly
  class DocumentGabcConvertor
    def initialize(document)
      @doc = document
    end

    def convert
      each_score_with_gabcname do |score, out_fname|
        File.open(out_fname, 'w') do |fw|
          GabcConvertor.new.convert score, fw
        end
        yield score, out_fname if block_given?
      end
    end

    # iterates over document scores,
    # yields score and filename of it's generated gabc file
    def each_score_with_gabcname
      @doc.scores.each_with_index do |score, si|
        yield score, output_fname(score, si)
      end
    end

    private

    def output_fname(score, score_index=nil)
      if @doc.scores.size == 1
        score_id = ''
      else
        score_id = '_' + (score.headers['id'] || score_index.to_s)
      end

      File.basename(@doc.path)
        .sub(/\.gly\Z/i, "#{score_id}.gabc")
    end
  end
end
