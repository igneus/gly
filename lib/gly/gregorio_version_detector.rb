module Gly
  class GregorioVersionDetector
    # Tries to determine version of available Gregorio.
    def self.version
      begin
        version_output = `gregorio --version`
      rescue Errno::ENOENT
        # 'gregorio' command not available
        return nil
      end

      version_output.match(/^Gregorio (\d+\.\d+\.\d+)/) do |m|
        return Gem::Version.new(m[1])
      end

      STDERR.puts 'Warning: failed to parse output of `gregorio --version`, Gregorio version unknown'
      nil
    end
  end
end
