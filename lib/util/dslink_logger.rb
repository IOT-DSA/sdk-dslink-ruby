# require 'logger'
require 'celluloid/autostart'
# Celluloid.logger = Logger
class DSLinkLogger
    include Celluloid
    include Celluloid::Logger


    DEBUG   = 0
    INFO    = 1
    WARN    = 2
    ERROR   = 3
    FATAL   = 4


    @@logger = self.new
    @@logger_level = DEBUG

    def self.level=(level)
        @@logger_level = {
            'debug' => DEBUG,
            'info' => INFO,
            'warn' => WARN,
            'error' => ERROR,
            'fatal' => FATAL,
        }[level.downcase]
    end


    def self.info(msg)
        Celluloid.logger.info(msg) if @@logger_level <= INFO
    end

    def self.warn(msg)
        Celluloid.logger.warn(msg) if @@logger_level <= WARN
    end

    def self.debug(msg)
        Celluloid.logger.debug(msg) if @@logger_level <= DEBUG
    end

    def self.fatal(msg)
        Celluloid.logger.fatal(msg) if @@logger_level <= FATAL
    end

    def self.error(msg)
        Celluloid.logger.error(msg) if @@logger_level <= ERROR
    end


end