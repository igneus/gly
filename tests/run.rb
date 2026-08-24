Dir[File.join(File.dirname(__FILE__), '*.rb')].each do |f|
  next if f == __FILE__
  require_relative File.basename f
end
