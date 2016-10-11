require 'net/http'
require 'yahoofinance'
require 'fox16'
require 'xmlsimple'

(puts 'Usage: ruby xml_ticker.rb HOSTNAME PORT_NUMBER'; exit) unless ARGV.length==2

class FXTickerApp
  include Fox
  def initialize(hostname, port_number, 
                font_size = 100, quote_frequency=1) 
                 
    #quote_frequency is in minutes
    
    @hostname = hostname
    @port_number = port_number
    @quote_frequency = quote_frequency

    load_symbols_from_server

    @fox_application=FXApp.new
    @main_window=FXMainWindow.new(@fox_application, "Stock Ticker ", 
                                  nil, nil, DECOR_ALL | LAYOUT_EXPLICIT)
    @tickerlabel = FXLabel.new(@main_window, get_label_text, 
                                  nil, 0,  LAYOUT_EXPLICIT)

    @tickerlabel.font.setFont "helvetica [bitstream],#{font_size}"

    def scroll_timer(sender, sel, ptr)
      self.scroll_label
      @fox_application.addTimeout(50, method(:scroll_timer)) 
    end
    @fox_application.addTimeout(50, method(:scroll_timer)) 

    def update_label_timer(sender, sel, ptr)
      @tickerlabel.text = self.get_label_text
      @fox_application.addTimeout(1000*60*@quote_frequency, 
                                  method(:update_label_timer)) 
    end
    @fox_application.addTimeout(1000*60*@quote_frequency, 
                                method(:update_label_timer)) 


    @fox_application.create
  end
  def load_symbols_from_server
    
    xml_body = Net::HTTP.new(@hostname, @port_number).get('/').body

    xml = XmlSimple.xml_in(xml_body)

    @symbols = xml['symbols'][0]['symbol']
  end

  def scroll_label
    if(@tickerlabel.x < -@tickerlabel.width)
      @tickerlabel.move(@main_window.width , @tickerlabel.y)
    else
      @tickerlabel.move(@tickerlabel.x - 3, @tickerlabel.y)
    end
  end

  def get_label_text
    label_text = ''
    YahooFinance::get_standard_quotes( @symbols ).each do |symbol, quote|
      label_text << "#{symbol}: #{quote.lastTrade} ... "
    end
    label_text
  end

  def go

    @main_window.show( PLACEMENT_SCREEN )

    @fox_application.run
  end
end

hostname = ARGV.shift
port_number = ARGV.shift

my_app = FXTickerApp.new(hostname, port_number, 240)
my_app.go

