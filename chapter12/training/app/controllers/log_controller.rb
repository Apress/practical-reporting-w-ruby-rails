class LogController < ApplicationController
  def upload
    if params[:commit]
      count = 0
      training_class = TrainingClass.find_by_id(params[:training_class_id])
      training_class_date = Date.parse(params[:training_class_date])
      params[:trainee].each do |index, t|
        next if t[:name]==''

        salesperson = Salesperson.find_or_create_by_name_and_employer( t[:name], t[:employer])
        
        g = Grade.create(:salesperson=>salesperson, :percentage_grade => t[:grade], :training_class=>training_class, :took_class_at=>training_class_date)
        g.save
        count = count +1
      end
      flash[:notice]="#{count} Entries Uploaded!"
    end
  end
  def all
    @grades = Grade.find(:all)
    render :layout=>false
  end
end
