require 'dbi'
require 'xmlsimple'
require 'yaml'
require 'open-uri'
require 'rubyscript2exe'
require 'swin'
database_path = ARGV[0]
unless database_path # If no path was specified on the command line, then ask for one.


	# You can find out more about Windows common dialogs here:
	# http://msdn2.microsoft.com/en-us/library/ms646949.aspx
	# You can find the header file with the full list of constants
	# here:
	# http://doc.ddart.net/msdn/header/include/commdlg.h.html
	
	OFN_HIDEREADONLY  =  0x0004
	OFN_PATHMUSTEXIST =  0x0800
	OFN_FILEMUSTEXIST =  0x1000

	filetype_filter =[['Access Database (*.mdb)','*.mdb'],
	   	  	 ['All files (*.*)', '*.*']]

    database_path = SWin::CommonDialog::openFilename(
                                        nil, 
                                        filetype_filter,
                                        OFN_HIDEREADONLY | 
                                        OFN_PATHMUSTEXIST | 
                                        OFN_FILEMUSTEXIST,
                                        'Choose a database')


  	
	exit if database_path.nil?
end

begin

  domain = 'localhost'
  port = '3000'

  xml = open("http://#{domain}:#{port}/log/all").read
  grades = XmlSimple.xml_in(xml)['grade']
  imported_count = 0
  DBI.connect("DBI:ADO:Provider=Microsoft.Jet.OLEDB.4.0;Data Source=#{database_path}") do |dbh|

    grades.each do |grade_raw|
      g ={}
      grade_raw.each do |key,value|
        if value.length == 1
          g[key] = value.first
        else
          g[key] = value
        end
      end
      #g.map! { g.length==1 ? g.first  : g}
      
      sql = "SELECT COUNT(*) 
           FROM grades
          WHERE id=?;"
      dbh.select_all(sql, g['id'].to_i) do |row|
        count = *row
        if count == 0
          sql = 'INSERT INTO  grades 
                     (id, student,
                      employer, grade,
                      class_date, class_name) 
                VALUES (?,?,?,?,?, ?);'
          dbh.do(sql, g['id'], g['student'],
                g['employer'], g['grade'],
                Date.parse(g['took_class_at']),
				g['class']
              );
          dbh.commit
          imported_count = imported_count + 1
        end        
      end
    end
  end
  
  SWin::Application.messageBox  "Done! #{imported_count} records imported.", "All done!"
#rescue
#  SWin::Application.messageBox  $!, "Error while importing"
end
