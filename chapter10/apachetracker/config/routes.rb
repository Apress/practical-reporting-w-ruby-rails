ActionController::Routing::Routes.draw do |map|
  map.connect '/', :controller=>'home'

  map.connect '/logs/', :controller=>"logs", 
                        :action=>'destroy', 
                        :conditions=>{:method=>:delete}


  map.connect '/logs/', :controller=>"logs", 
                        :action=>'create', 
                        :conditions=>{:method=>:post}

  map.connect '/traffic_reports.pdf', 
                        :controller=>'report',
                        :action=>'show',
                        :format=>'pdf'

  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
