module MemoryProfiler
  class Helpers

    def initialize
      @gem_guess_cache = Hash.new
      @location_cache = Hash.new { |h,k| h[k] = Hash.new.compare_by_identity }
      @class_name_cache = Hash.new.compare_by_identity
    end

    def guess_gem(path)
      @gem_guess_cache[path] ||=
        if /(\/gems\/.*)*\/gems\/(?<gemname>[^\/]+)/ =~ path
          gemname
        elsif /\/rubygems[\.\/]/ =~ path
          "rubygems".freeze
        elsif /(?<app>[^\/]+\/(bin|app|lib))/ =~ path
          app
        else
          "other".freeze
        end
    end

    def lookup_location(file, line)
      @location_cache[file][line] ||= "#{file}:#{line}"
    end

    def lookup_class_name(klass)
      unless @class_name_cache[klass]
        if klass
          if klass.respond_to? :name
            val = klass.name
          elsif Celluloid::Proxy::Async === klass
            val = "Celluloid::Proxy::Async"
          else
            val = klass.to_s.match(/<(.*?)(:0x\w+)?>/)[1]
          end
        else
          val = '<<Unknown>>'
        end
        @class_name_cache[klass] = val
      end
      @class_name_cache[klass]
    end

  end
end
