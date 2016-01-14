module Gly; end

%w(parser
gabc_convertor
parsed_score
headers
lyrics
document
document_gabc_convertor
document_ly_convertor
gly_convertor
preview_generator
preview_builder
lister
string_helpers).each do |mod|
  require "gly/#{mod}"
end
