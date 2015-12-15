module Gly; end

%w(parser gabc_convertor parsed_score headers lyrics document string_helpers).each do |mod|
  require "gly/#{mod}"
end
