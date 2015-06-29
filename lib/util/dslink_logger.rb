require 'logger'

class DSLinkLogger
    @@logger = Logger.new STDOUT
    @@logger.level = Logger::DEBUG

    @@logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime}][#{severity}] #{msg}\n"
    end

    def self.level=(level)
        @@logger.level = {
            'debug' => Logger::DEBUG,
            'info' => Logger::INFO,
            'warn' => Logger::WARN,
            'error' => Logger::ERROR,
            'fatal' => Logger::FATAL,
        }[level.downcase]
    end

    def self.log(msg)
        @@logger.log(msg)
    end

    def self.info(msg)
        @@logger.info(msg)
    end

    def self.warn(msg)
        @@logger.warn(msg)
    end

    def self.debug(msg)
        @@logger.debug(msg)
    end

    def self.fatal(msg)
        @@logger.fatal(msg)
    end

    def self.error(msg)
        @@logger.error(msg)
    end

    def self.unkown(msg)
        @@logger.unkown(msg)
    end


end