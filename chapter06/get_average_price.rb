require 'rexml/document'
require 'net/http'
require 'uri'

require 'hpricot'

(puts "usage: #{$0} keyword1,keyword2 seller1,seller2"; exit) unless ARGV.length==2

keywords=ARGV.shift.split(',')
sellers=ARGV.shift.split(',')
sellers << nil # This is an "all sellers" line; note that you can delete this line if
               # you do not want your output to display an average for all sellers.

path_to_pdflatex = '' # Insert your path to pdflatex here.

$ebay_config = {
  :ebay_address=> 'rest.api.ebay.com',
  :request_token => '', 
  :user_id => '' }   #Insert your request token and user ID here .

class String
	def latex_escape()

		replacements= {  '\\' =>'$\backslash$',
                         '$'=>'\$',
                         '%'=>'\%',
                         '&'=>'\&',
                         '_'=>'\_',
                         '~'=>'*~*',
                         '#'=>'\#',
                         '{'=>'$\{$',
                         '}'=>'$\}$',
                        }
		self.gsub(/[#{replacements.keys.join('|')}]/) do |match|
			replacements[match]
		end

	end
end

class EBaySearch

  def self.get_average_price(keyword, seller_id=nil)
  
  params = {   
    # Authorization information...
    'RequestToken' => $ebay_config[:request_token],
    'RequestUserId' => $ebay_config[:user_id],

    # Function name.
    'CallName' => 'GetSearchResults',

    # Search parameters
    'Query'=>URI.escape(keyword), # Note that only 
           # some parameters are escaped.
           # This is because the RequestToken
           # is already escaped for URLs, so 
           # re-URLencoding would cause 
           # problems; otherwise, we could just
 	       # run all of these values a URI.escaping 
           # loop.

    'ItemTypeFilter' => 3,   # Search all items, 
           # including fixed price items.

    'SearchInDescription'=>0,# Do not search inside of
           # description.

    # Return data parameters
    'Schema' =>1, # Use eBay's new style XML schema instead of
	              # of the old, deprecated one.
    'EntriesPerPage' =>100, # Return at most 100 entries - 
	                        # note that for performance reasons,
	                        # this code does not iterate through the pages,
	                        # so it will only calculate the average of
	                        # the first hundred items on eBay.
    'PageNumber' =>1

    }

  if seller_id # If the caller does not pass a seller id,
    # this function will search across all sellers.

    params['IncludeSellers'] = URI.escape(seller_id)

    # eBay usernames are currently limited to alphanumeric characters
    # and underscores, so this may not be necessary, but it's escaped
    # just in case.
  end

  url= "/restapi?"<< params.map{|param, value| "#{param}=#{value}"}.join("&")

  response = Net::HTTP.get_response($ebay_config[:ebay_address], url)
  hpricot_doc = Hpricot.XML(response.body)

  total_price= 0.0
  result_count=0

  (hpricot_doc/:SearchResultItem).each do |item| # Iterate through each SearchResultItem
    price_element = (item/:CurrentPrice)  # Find the CurrentPrice element for each element
    if price_element # If it has a price...
      total_price = total_price +  price_element.first.innerHTML.to_f #... then pull out the
	                                                                  # inside of the element,
	                                                                  # convert it to a float,
	                                                                  # and add it to the total.
      result_count = result_count + 1
	end
  end 

  if result_count > 0
    average_price = (total_price/result_count) 
  else
    average_price = nil 
  end

  [result_count, average_price] # Return the number of results and average price as an array.

  end

end

temporary_latex_file='average_price_report.tex' # This filename will also control 
	                                            # the output file name - the file
                                                # will be named average_price_report.pdf
	                                            
	                                                                  


latex_source='
\documentclass[8pt]{article}

\begin{document}

\huge                                    % Switch to huge size and
\textbf{Competitor Average Price Report} % print a header at the
                                         % top of the page.

\vspace{0.1in}                           % Add a small amount of
                                         % whitespace between the
                                         % header and the table

\normalsize                              % Switch back to normal size.

\begin{tabular}{llll}                    % Start a table with four 
                                         % left aligned columns.

\textbf{Item}&                           % Four headers, each in bold,
\textbf{Seller}&                         % with labels for each column.
\textbf{Count}& 
\textbf{Average Price}\\\\

'

keywords.each do |keyword|
	first=true
  sellers.each do |seller|
    total_items, average_price = *EBaySearch.get_average_price(keyword, seller)

    latex_source << " 
    \\textbf{#{first ? keyword.latex_escape : ' '}} & 
    #{seller ? seller.latex_escape : 'First 100 eBay Results'} &
    #{total_items} & 
    \\#{average_price ? ('$%0.2f' % average_price) : ''}
    \\\\  " 

	# Note that the character & is the marker for the end of a cell, and
	# that the sequence \\\\ is two escaped backslashes, which marks 
	# the end of the row.
	
    first=false # This marker controls whether to redisplay the keyword.
	            # For visual formatting reasons, each keyword is only
	            # shown once.
  end
end

latex_source << '
\end{tabular}
\end{document}'

fh = File.open(temporary_latex_file, 'w')
fh.puts latex_source
fh.close
puts "Searched #{keywords.length} keywords and #{sellers.length} sellers for a total of #{sellers.length*keywords.length} eBay searches."
puts `"#{path_to_pdflatex}" #{temporary_latex_file} --quiet` # Runs PDFLatex with 
# the --quiet switch, which eliminates much of the chatter it usually displays.
# It will still display errors, however.
puts "Wrote report to average_price_report.pdf"
