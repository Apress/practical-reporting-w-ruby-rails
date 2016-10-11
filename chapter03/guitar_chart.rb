require 'gruff'

line_chart = Gruff::Bar.new()
line_chart.labels = {0=>'Value (USD)'}
line_chart.title = "My Guitar Collection"

{"'70 Strat"=>2500,
 "'69 Tele"=>2000,
 "'02 Modded Mexi Strat Squier"=>400}.each do |guitar, value|
  line_chart.data(guitar, value )
 end

