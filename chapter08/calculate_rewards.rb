require 'active_record'
require 'benchmark' 
require 'erubis'


ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :host     => 'localhost',
  :port    => 3307,
  :username => 'root',  # This is the default username and password
  :password => '',      # for MySQL, but note that if you have a
                        # different username and password,
                        # you should change it.
  :database => 'sugarcrm')


path_to_ps2pdf = 'C:\Program Files\MiKTeX 2.6\miktex\bin\ps2pdf.bat' #Insert your path to ps2pdf here.
path_to_html2ps = 'C:\Perl\bin\perl.exe" "C:\Program Files\html2ps\html2ps' #Insert your path to html2ps here.

# Windows can't run perl scripts directly, 
# so Windows users should preface their html2ps
# path with their perl path, so that it looks 
# something like this:
# path_to_html2ps = 'C:\perl\bin\perl.exe" "c:\path\to\html2ps'
#
# Note the double qoutes after perl.exe and before the script filename;
# this ensures that the string is interpolated like this:
# "c:\perl\bin\perl.exe" "c:\path\to\html2ps"
#
# Without the extra double quotes, Windows will look for an program 
# named "C:\perl\bin\perl c:\path\to\html2ps", and since once 
# does not exist, it will cause problems.

class User < ActiveRecord::Base
    has_many :meetings, :foreign_key=>:assigned_user_id
    def reward
        Reward.find(:first, 
                    :conditions=>['meeting_count < ? ',
                                  self.meetings.count],
                    :order=>'meeting_count DESC',
                    :limit=>1) 
    end
end

class Meeting < ActiveRecord::Base
end

class Reward < ActiveRecord::Base
end

users = User.find(:all, 
          :conditions=>['not is_admin'],
          :order=>'last_name ASC, first_name ASC' 
         )

eruby_object= Erubis::Eruby.new(File.read('rewards_report_template.rhtml'))
context = { :users=>users }
html = eruby_object.evaluate(context)

ps_source = '' 

open('|"'+path_to_html2ps+'"', 'wb+') do |process_handle|
    process_handle.puts html
    process_handle.close_write
    ps_source = process_handle.read
end

pdf_source = ''

open('|"' + path_to_ps2pdf +'" - -', 'wb+') do |process_handle|
    process_handle.puts ps_source
    process_handle.close_write
    pdf_source = process_handle.read
end

File.open('report.pdf','wb+') do |pdf_file_handle|
    pdf_file_handle.puts pdf_source
end

