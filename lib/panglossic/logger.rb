module Panglossic
  class Logger
    FATAL = 4
    ERROR = 3
    WARN  = 2
    INFO  = 1
    DEBUG = 0
    
    def initialize options={}
      if level = options[:level]
        case level
        when :fatal
          @level = FATAL
        when :error
          @level = ERROR
        when :warn
          @level = WARN
        when :info
          @level = INFO
        when :debug
          @level = DEBUG
        else
          raise ArgumentError.new "invalid value for logger level: must be one of :debug, :info, :warn, :error, :fatal"
        end
      else
        @level = DEBUG
      end
    end
    
    def error msg
      if @level >= ERROR
        log msg, "ERROR"
      end
    end
    
    def warn msg
      if @level >= WARN
        log msg, "WARN"
      end
    end
    
    def fatal msg
      if @level >= FATAL
        log msg, "FATAL"
      end
    end
    
    def info msg
      if @level >= INFO
        log msg, "INFO"
      end
    end
    
    def debug msg
      if @level >= DEBUG
        log msg, "DEBUG"
      end
    end
    
    def log msg, tag=nil
      if tag
        puts((tag.to_s + ":").ljust(7) + msg)
      else
        puts msg
      end
    end
  end
end
