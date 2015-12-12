module Gly; end

%w(parser gabc_convertor parsed_score headers lyrics document).each do |mod|
  require "gly/#{mod}"
end
