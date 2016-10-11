require 'active_record'
require 'fastercsv'

(puts "usage: #{$0} csv_filename"; 
       exit) unless ARGV.length==1

paypal_source_file = ARGV.shift

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :host     => 'localhost',
  :username => 'root',
  :password => '',
  :database => 'paypal')


class PaypalTransaction <  ActiveRecord::Base
end

class String
  def columnize
    self.strip.downcase.gsub(/[^a-z0-9_]/, '_')
  end
end

max_gross=0
date_fields = ['date' ]
float_fields = ['gross', 'fee', 'net']
cols = {}
weeks = []

first = true

FasterCSV.foreach(paypal_source_file) do |line|

  if first
    first=false
    line.each_with_index do |field_name, field_position|
      next if field_name.strip ==''

      cols[field_name.columnize] = field_position
    end

    unless PaypalTransaction.table_exists?
      ActiveRecord::Schema.define do
        create_table PaypalTransaction.table_name do |t|
          cols.each do |col, col_index|

            if date_fields.include?(col)
              t.column col, :date
            elsif float_fields.include?(col)
              t.column col, :float
            else
              t.column col, :string
            end

          end
        end
      end
    end
    
  else
    if PaypalTransaction.count_by_sql("SELECT COUNT(*) 
                                       FROM paypal_transactions 
                                       WHERE transaction_id
                                             ='" <<
                                               line[cols[
                                                'Transaction ID'.columnize
                                                   ]    ] << 
                                             "';")==0
      PaypalTransaction.new do |transaction|
        cols.each do |field_name, field_position|
        
          transaction .send("#{field_name }=", line[field_position])

        end
        transaction .save
      end
    end
  end
end

