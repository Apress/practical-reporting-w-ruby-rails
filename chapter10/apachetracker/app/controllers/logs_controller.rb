require 'benchmark'
require 'tempfile'
require 'csv'
require 'ftools'

class LogsController < ApplicationController
	def create 
		flash[:notice] = "Uploaded new file... \n"
		count=0
		if params[:upload_with_active_record]
			real_time_elapsed = Benchmark.realtime  do
				LogParser.new.parse_io_stream(params[:log][:file]) do |l|
					Hit.create(
						:user_agent => l['HTTP_USER_AGENT'],
						:path_info => l['PATH_INFO'],
						:remote_addr => l['REMOTE_ADDR'],
						:http_referrer => l['HTTP_REFERER'],
						:status => l['STATUS'],
						:visited_at => l['DATETIME']
                        )
					end
					count = count + 1
				end 
				
		elsif params[:upload_with_active_record_extensions]
			real_time_elapsed = Benchmark.realtime  do
				columns = [:user_agent, :path_info, :remote_addr, :http_referrer, :status, :visited_at]
				values = []
				LogParser.new.parse_io_stream(params[:log][:file]) do |l|
					values << 
					[
						l['HTTP_USER_AGENT'],
						l['PATH_INFO'],
						l['REMOTE_ADDR'],
						l['HTTP_REFERER'],
						l['STATUS'],
						Date.parse(l['DATETIME'])
					]
					count = count + 1
				end
				Hit.import columns, values if values.length>0
			end
		end
		
		flash[:notice] << " #{count} uploaded, #{Hit.count} total\n"
		flash[:notice] << " #{'%0.2f' % real_time_elapsed} elapsed, #{(count.to_f/real_time_elapsed)*60} records per minute ."
		redirect_to :controller=>:home, :action=>:index
		
	end
	def destroy 
		Hit.delete_all
		flash[:notice] = 'Logs cleared!'
		redirect_to :controller=>:home, :action=>:index
	end
end
