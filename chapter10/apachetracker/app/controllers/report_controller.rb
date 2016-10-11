require 'tempfile'
require 'gruff'
require 'scruffy'

class ReportController < ApplicationController

 def show 
    @rails_pdf_inline  = true
 
    @graph_files ={ 'Graph of per-sale costs'=>get_sale_graph_tempfile,
                    'Graph of total visitors from each advertiser'=>get_visitor_graph_tempfile 
                  }
    render :action=>:graphs, :layout=>nil
    @graph_files.each do |key, filename|
      File.unlink filename
    end
  end

  protected

  def get_tempfile_name(core)
    File.join(RAILS_ROOT, "tmp/#{core}_#{request.env['REMOTE_ADDR']}_#{Time.now.to_i}.jpg")
  end

  def get_visitor_graph_tempfile
    graph_tempfile_name = get_tempfile_name('visitor_graph')

    advertisers = Advertiser.find(:all)    
    
    g = Gruff::Bar.new(1000)
    g.title = "Advertisting Traffic Report" 
    g.legend_font_size = 16
    advertisers.each do |a|
      vistor_addresses  = Hit.find(:all,
                    :group=>'remote_addr',
                    :conditions=>['http_referrer= ? ', 
                    a.referrer_url]
                    ).map { |h| h.remote_addr }
      
      sale_count = Hit.count('remote_addr',
                    :conditions=>['remote_addr IN (?)
                      AND
                      path_info LIKE "/cart/checkout%"',
                        vistor_addresses])

      g.data(a.company_name, [ vistor_addresses.length, sale_count ] )
    end

    g.labels = {0 => 'Visitors', 1 => 'Visitors With One or More Purchases' }

    g.write(graph_tempfile_name)
    graph_tempfile_name
  end

  def get_sale_graph_tempfile
    graph_tempfile_name = get_tempfile_name('sale_graph_tempfile')

    advertisers = Advertiser.find(:all)    
    
    g = Gruff::Bar.new(1000)
    
    g.title = "Cost Per Sale Report" 
    g.legend_font_size = 16
    g.y_axis_label = 'Cost (USD)'

    advertisers.each do |a|
      vistor_addresses  = Hit.find(:all,
                    :group=>'remote_addr',
                    :conditions=>['http_referrer= ? ', 
                    a.referrer_url]
                    ).map { |h| h.remote_addr }
      total_cost = vistor_addresses.length*a.cost_per_click

      sale_count = Hit.count('remote_addr',
                    :conditions=>['remote_addr IN (?)
                      AND
                      path_info LIKE "/cart/checkout%"',
                        vistor_addresses])
      cost_per_sale = total_cost / sale_count 

      g.data(a.company_name, [a.cost_per_click, cost_per_sale ] )
    end

    g.labels = {0 => 'Cost Per Click', 1 => 'Cost Per Sale' }
    g.minimum_value = 0

    g.write(graph_tempfile_name)
    graph_tempfile_name
  end

  def rescue_action_in_public(exception)
   headers.delete("Content-Disposition")
   super
  end

  def rescue_action_locally(exception)
   headers.delete("Content-Disposition")
   super
  end 
    
end
