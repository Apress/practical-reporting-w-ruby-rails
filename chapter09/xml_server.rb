require 'mongrel'
require 'fastercsv'
require 'remarkably/engines/xml'

(puts "usage: #{$0} csv_file_1 csv_file_2..."; exit) unless ARGV.length >=1

class StocksList
  def initialize
	  @symbols = []    # holds our list of symbols
  end

  def load_csv(files)
    @symbols = []
    valid_symbol_labels = ['Symbol']
    files.each do |file|
      rows = FasterCSV.parse(open(file))
      first_row= rows.shift
      symbol_index = nil

      first_row.each_with_index do |label, index|
        if(valid_symbol_labels.include?(label))
          symbol_index = index
          break
        end
      end
      if symbol_index.nil?
        puts "Can't find symbol index on first row in file #{file}."
     else
        @symbols = @symbols + rows.map { |r| r[symbol_index] 
                             }.delete_if { |s| s.nil? or s =='' }
      end
    end    
  end

  include Remarkably::Common
  def to_xml
      xml do
        symbols do
        @symbols.each do |s|
          symbol s
        end          
        end
      end.to_s
  end


end


class StocksXMLHandler < Mongrel::HttpHandler
  def initialize(stocks_list)
	  @stocks_list = stocks_list
	  super()
  end
  def process(request, response)
    response.start(200) do |headers, output_stream|
      headers["Content-Type"] = "text/plain"
      
      output_stream.write(@stocks_list.to_xml)
    end
  end
end


stocks_list = StocksList.new
stocks_list.load_csv(ARGV)

interface = '127.0.0.1'
port = '3000'

mongrel_server = Mongrel::HttpServer.new( interface, port)
mongrel_server.register("/", StocksXMLHandler.new(stocks_list))
puts "** Fidelity XML server started on #{interface}:#{port}!"
mongrel_server.run.join


