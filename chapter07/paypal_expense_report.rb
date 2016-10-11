require 'active_record'
require 'fastercsv'
require 'yaml'
require 'markaby'

(puts "usage: #{$0} mysql_hostname mysql_username " <<
      "mysql_password database_name"; exit) unless ARGV.length==4

mysql_hostname,
mysql_username,
mysql_password,
mysql_database= *ARGV

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => mysql_hostname,
  :username => mysql_username,
  :password => mysql_password,
  :database => mysql_database)  # Establish a connection to the database.


class PaypalTransaction <  ActiveRecord::Base 
end

first = true
c = {}


sql = "
SELECT  WEEK(p1.date) + 1 as week_number,
    YEAR(p1.date) as year,
    COALESCE((SELECT SUM(ABS(p2.gross)) 
           FROM paypal_transactions as p2
          WHERE (WEEK(p2.date) = WEEK(p1.date)
            AND YEAR(p2.date) = YEAR(p1.date)
            AND WEEKDAY(p2.date) IN (5,6)
            AND p2.gross<0
            AND p2.status='Completed')
    ),0) as weekend_amount,

    COALESCE((SELECT SUM(abs(p3.gross)) 
           FROM paypal_transactions as p3
          WHERE (WEEK(p3.date) = WEEK(p1.date)
            AND YEAR(p3.date) = YEAR(p1.date)
            AND WEEKDAY(p3.date) NOT IN (5,6)
            AND p3.gross<0
            AND p3.status='Completed')
    ),0) as weekday_amount

    FROM paypal_transactions as p1
  
    GROUP BY YEAR(date) ASC,  WEEK(date) ASC;
" 

weeks = []

max_gross=0.0

PaypalTransaction.find_by_sql(sql).each do |week|
  # First, if the weekday is the highest total spending we've seen so far,
  # we'll keep that value to calibrate the size of the graph...

  max_gross = week.weekday_amount.to_f  if week.weekday_amount.to_f > max_gross

  # ... and if the weekend spending is the highest, we'll use that:

  max_gross = week.weekend_amount.to_f  if week.weekend_amount.to_f > max_gross

  # We'll add a hash with the week number ,the year,
  # the weekday spending, and the weekend spending to the weeks array:

  weeks << {   :week_number=>week.week_number.to_i,
               :year=>week.year.to_i,
               :weekday_amount=>week.weekday_amount.to_f,
               :weekend_amount=>week.weekend_amount.to_f
        }
end

mab =  Markaby::Builder.new() do 
  html do 
    head do
      title 'PayPal Spending Report'
	  style  :type => "text/css" do %[
		  .weekday_bar { display:block; background-color: blue; }
		  .weekend_bar { display:block; background-color: red; }
		%]
	  end
    end
    body do
      h1 ''
      table do
        weeks.each do |week|
          tr do
            th :style=>"vertical-align:top;" do 
              p "Week \##{week[:week_number]}, #{week[:year]}" 
            end
            td do
              div :class=>:weekday_bar,
				  :style=>"width:" << ((week[:weekday_amount] /
                                       max_gross * 199 ) + 1).to_s  do
                "&nbsp;"
              end
              span "Week - $#{'%0.2f' % week[:weekday_amount]}"
            end
          end
          tr do
            td ""
            td do
              div :class=>:weekend_bar, 
				  :style=>"width: " << ((week[:weekend_amount] / 
                                      max_gross * 199) + 1 ).to_s  do
                '&nbsp;'
              end
              span "Weekend - $#{'%0.2f' % week[:weekend_amount]}" 
            end
          end
        end
      end
    end
  end
end

puts mab

