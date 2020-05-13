module Gly; end

%w(parser
exceptions
gabc_convertor
score
headers
lyrics
markup
music_with_lyrics
document
document_gabc_convertor
document_ly_convertor
gly_convertor
preview_generator
preview_builder
lister
tags
gregorio_version_detector
string_helpers).each do |mod|
  require "gly/#{mod}"
end
