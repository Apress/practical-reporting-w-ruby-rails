#!/usr/bin/ruby
# This program parses weblogs in the NCSA Common (access log) format or
# NCSA Combined log format
#
# One line consists of
#  host rfc931 username date:time request statuscode bytes
# For example
#  1.2.3.4 - dsmith [10/Oct/1999:21:15:05 +0500] "GET /index.html HTTP/1.0" 200 12
#                   [dd/MMM/yyyy:hh:mm:ss +-hhmm]
# Where
#  dd is the day of the month
#  MMM is the month
#  yyy is the year
#  :hh is the hour
#  :mm is the minute
#  :ss is the seconds
#  +-hhmm is the time zone
#
# In practice, the day is typically logged in two-digit format even for 
# single-digit days. 
# For example, the second day of the month would be represented as 02. 
# However, some HTTP servers do log a single digit day as a single digit. 
# When parsing log records, you should be aware of both possible day 
# representations.
#
# Author:: Jan Wikholm [jw@jw.fi]
# License:: MIT

require 'logger'

class LogFormat
  attr_reader :name, :format, :format_symbols, :format_regex

  # add more format directives here..
  DIRECTIVES = {
    # format string char => [:symbol to use, /regex to use when matching against log/]
    'h' => [:ip, /\d+\.\d+\.\d+\.\d+/],
    'l' => [:auth, /.*?/],
    'u' => [:username, /.*?/],
    't' => [:datetime, /\[.*?\]/],
    'r' => [:request, /.*?/],
    's' => [:status, /\d+/],
    'b' => [:bytecount, /-|\d+/],
    'v' => [:domain, /.*?/],
    'i' => [:header_lines, /.*?/], 
  }

  def initialize(name, format)
    @name, @format = name, format
    parse_format(format)
  end
  
  # The symbols are used to map the log to the env variables
  # The regex is used when checking what format the log is and to extract data
  def parse_format(format)
    format_directive = /%(.*?)(\{.*?\})?([#{[DIRECTIVES.keys.join('|')]}])([\s\\"]*)/

    log_format_symbols = []
    format_regex = ""
    format.scan(format_directive) do |condition, subdirective, directive_char, ignored|
      log_format, match_regex = process_directive(directive_char, subdirective, condition)
      ignored.gsub!(/\s/, '\\s') unless ignored.nil?
      log_format_symbols << log_format
      format_regex << "(#{match_regex})#{ignored}"
    end
    @format_symbols = log_format_symbols
    @format_regex =  /^#{format_regex}/
  end

  def process_directive(directive_char, subdirective, condition)
    directive = DIRECTIVES[directive_char]
    case directive_char 
    when 'i'
      log_format = subdirective[1...-1].downcase.tr('-', '_').to_sym
      [log_format, directive[1].source]
    else
      [directive[0], directive[1].source]
    end
  end
end

class LogParser

  LOG_FORMATS = {
    :common => '%h %l %u %t \"%r\" %>s %b',
    :common_with_virtual => '%v %h %l %u %t \"%r\" %>s %b',
    :combined => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    :combined_with_virtual => '%v %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    :combined_with_cookies => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" \"%{Cookies}i\"',
  }

  # add any values that you may return here
  STAT_ENV_MAP = {
    :referer => "HTTP_REFERER",
    :user_agent => "HTTP_USER_AGENT",
    :ip => "REMOTE_ADDR",
    :page => "PATH_INFO",
    :domain => "HTTP_HOST",
    :datetime => 'DATETIME',
    :status => 'STATUS'
  }
  
  attr_reader :known_formats

  @@log = ActiveRecord::Base.logger
  
  def initialize()
    @log_format = []
    initialize_known_formats
  end

  # processes the format string into symbols and test regex
  # and saves using LogFormat class
  def initialize_known_formats
    @known_formats = {}
    LOG_FORMATS.each do |name, format|
      @known_formats[name] = LogFormat.new(name, format)
    end
  end


  # Checks which standard the log file (well one line) is
  # Automatigally checks for most complex (longest) regex first..
  def check_format(line)
    @known_formats.sort_by { |key, log_format| log_format.format_regex.source.size }.reverse.each { |key, log_format|
      #@@log.debug "check format: #{key}"
      return key if line.match(log_format.format_regex)
    }
    return :unknown
  end
  
  # This is where the magic happens
  # This is the end-to-end business logic of the class
  #
  # Call with a block that will be called with each line, as a hash
  def parse_io_stream(stream)
    stats = []
    lines_parsed = 0
    begin
      stream.each do |line|
        lines_parsed += 1
        #@@log.debug("parse_io_stream() line: #{line.to_s}")        
        raw_data = parse_line(line)
        #@@log.debug(raw_data.inspect)        
        #@@log.debug("parse_io_stream() lines parsed: #{lines_parsed}")
        yield generate_stats(raw_data)
      end
    end
  end

  # Generate_stats will populate a stats hash one line at a time
  # Add extra fields into the STAT_ENV_MAP hash at the top of this file.
  def generate_stats(raw_data)
    stats = { "PATH_INFO" => get_page(raw_data[:request]) }
    STAT_ENV_MAP.each do |stat_name, env_name|
      stats[env_name] = raw_data[stat_name] if raw_data.has_key? stat_name
    end
    #@@log.debug("stats: " + stats.inspect)        
    stats
  end

  def get_page(request)
    @@log.debug "get_page: #{request}"
    request[/\/.*?\s/].rstrip
  end  

  def parse_line(line)
    @format = check_format(line)
    log_format = @known_formats[@format]
    raise ArgumentError if log_format.nil? or line !~ log_format.format_regex
    data = line.scan(log_format.format_regex).flatten
    #@@log.debug "parse_line() scanned data: #{data.inspect}"
    parsed_data = {}
    log_format.format_symbols.size.times do |i|
      #@@log.debug "setting #{log_format.format_symbols[i]} to #{data[i]}"
      parsed_data[log_format.format_symbols[i]] = data[i]
    end

    #remove [] from time if present
    parsed_data[:datetime] = parsed_data[:datetime][1...-1] if parsed_data[:datetime]
    # Add ip as domain if we don't have a domain (virtual host)
    # Assumes we always have an ip
    parsed_data[:domain] = parsed_data[:ip] unless parsed_data[:domain]
    parsed_data[:format] = @format
    #@@log.debug "parse_line() parsed data: #{parsed_data.inspect}"
    parsed_data
  end
end
