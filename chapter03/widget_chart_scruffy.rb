require 'scruffy'

sprocket_output = {"Jan"=>500,
                   "Feb"=>750,
                   "Apr"=>380}

widget_output =   {"Jan"=>350,
                   "Feb"=>650,
                   "Apr"=>560}

graph = Scruffy::Graph.new(
                   :title => "Widget and Sprocket Output",
                   :theme => Scruffy::Themes::Keynote.new)

graph.add(:bar, 'Sprockets', sprocket_output.values)
graph.add(:line, 'Widgets', widget_output.values)

graph.point_markers = widget_output.keys

graph.render(      :width => 800, 
                   :as=>'PNG', 
                   :to => "widgets_and_sprockets.png")

