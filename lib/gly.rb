module Gly; end

%w(parser
gabc_convertor
parsed_score
headers
lyrics
document
document_gabc_convertor
preview_generator
lister).each do |mod|
  require "gly/#{mod}"
end
