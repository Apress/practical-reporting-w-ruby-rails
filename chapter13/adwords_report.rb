require 'active_record'
require 'ruport'

class AdResult < ActiveRecord::Base
end

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
