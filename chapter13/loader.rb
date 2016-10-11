require 'hpricot'
require 'active_record'

hpricot_doc = Hpricot.XML(ARGF)

ActiveRecord::Base.establish_connection(
               :adapter=>'mysql',
    		   :host=>'127.0.0.1',
               :database=>'text_ad_report',
               :username=>'root',
               :password=>'')

# This is the default username and password
# for MySQL, but note that if you have a
# different username and password,
# you should change it.

class AdResult < ActiveRecord::Base
end

rows=(hpricot_doc/"rows/row")

unless AdResult.table_exists?
  first_row = rows.first # We'll use this row as a model
                         # to create the database schema

  field_override_types = {
                 'imps'=>:integer,
                 'clicks'=>:integer,
                 'ctr'=>:float,
                 'cpc'=>:integer,
                 'cost'=>:integer
                         }

  ActiveRecord::Schema.define do
    create_table AdResult.table_name do |t|
          first_row.attributes.each do |attribute_name, value|
              if field_override_types.include?(attribute_name)
				  t.column attribute_name, field_override_types[attribute_name]
			  else
				  t.column attribute_name, :text, :length=>25
              end              
	       end
    end
  end

end


rows.each do |row| 
   AdResult.new do |n|
	  row.attributes.each do |attribute_name, attribute_value|
		  n.send("#{attribute_name}=", attribute_value)
	  end
	  n.save
   end
end
