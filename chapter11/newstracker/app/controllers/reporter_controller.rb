class ReporterController < ApplicationController
  def index
    custom_sql = "SELECT published_at_formatted,
                         count(*) as count

                    FROM (SELECT DATE_FORMAT(published_at,
                                             '%m-%d-%y') 
                                 AS published_at_formatted
                            FROM stories) AS grouped_table
                   GROUP 
                      BY published_at_formatted
                   ;"

    @stories = Story.find_by_sql(custom_sql)
  end
end
