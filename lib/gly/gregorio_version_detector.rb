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

      # failed to parse gregorio version from the output
      nil
    end
  end
end
