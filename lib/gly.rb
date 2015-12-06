module Gly; end

%w(parser gabc_convertor parsed_score headers lyrics).each do |mod|
  require "gly/#{mod}"
end
