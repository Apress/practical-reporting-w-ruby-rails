class BudgetOptimizerController < ApplicationController
  def index
  end

  def report
    @excel_view = params[:view_as_excel]
    @target_clicks=params[:target_clicks].to_f

    results_raw=AdResult.find(:all, 
                           :select=>'headline,
                                     AVG(cost) as cost,
                                     AVG(clicks) as clicks',
                           :group=>'headline')

    results_raw.sort! { |x,y| (x.cost/x.clicks <=> y.cost/y.clicks) }
    @results = []
    click_sum = 0.0
    results_raw.each do |r|
     @results <<  r 
     click_sum += r.clicks
     break if click_sum > @target_clicks
    end
    @estimated_clicks = click_sum
    @avg_cost_per_click = (
                    @results.inject(0.0) { |sum,r|  sum+=r.cost } )   /  (
                    @results.inject(0.0){ |sum,r|  sum+= r.clicks } )
    if @excel_view
      headers['Content-Type'] = "application/vnd.ms-excel" 
      headers['Content-Disposition'] = 'attachment; filename="adwords_report.xls"'
    end
  end
end

