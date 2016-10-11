require 'feed_tools'
require 'active_record'
require 'uri'

query = ARGV[0]
query_encoded = URI.encode(query)

if File.exists?('./config/database.yml')
  require 'yaml'
  ActiveRecord::Base.establish_connection(
                  YAML.load(File.read('config/database.yml'))['development'])
else
  ActiveRecord::Base.establish_connection(
    :adapter  => "mysql",
    :host     => "127.0.0.1",
    :username => "root",
    :password => "",
    :database => "company_pr")
end

class Stories <  ActiveRecord::Base
end

unless Stories.table_exists?
  ActiveRecord::Schema.define do
    create_table :stories do |t|
      t.column :guid, :string
      t.column :title, :string 
      t.column :source, :string
      t.column :url, :string
      t.column :published_at, :datetime
      t.column :created_at, :datetime
    end
    create_table :cached_feeds do |t|
      t.column :url , :string
      t.column :title, :string
      t.column :href, :string
      t.column :link, :string
      t.column :feed_data, :text
      t.column :feed_data_type, :string, :length=>25
      t.column :http_headers, :text
      t.column :last_retrieved, :datetime
   end 

   # Without the following line,
   # you can't retrieve large results - 
   # like those we use in this script.

   execute "ALTER TABLE cached_feeds 
          CHANGE COLUMN feed_data feed_data MEDIUMTEXT;"
  end
end

output_format = 'rss'
per_page = 100

feed_url = "http://news.google.com/news" <<
           "?hl=en&ned=us&ie=UTF-8" <<
       "&num=" << per_page <<  
           "&output=" << output_format <<
           "&q=" << query_encoded

FeedTools.configurations[:feed_cache] =  "FeedTools::DatabaseFeedCache"

feed=FeedTools::Feed.open(feed_url)

unless feed.live? 
  # replace the previous line with "unless false" to 
  # disable the cache.

  puts "feed is cached..." 
  puts "last retrieved: #{ feed.last_retrieved }"
  puts "expires: #{ feed.last_retrieved + feed.time_to_live }"
else
  feed.items.each do |feed_story|
    if not (Stories.find_by_title(feed_story.title) or
            Stories.find_by_url(feed_story.link) or
            Stories.find_by_guid(feed_story.guid))
      puts "processing story '#{feed_story.title}' - new"
      Stories.new do |new_story|
        new_story.title=feed_story.title.gsub(/<[^>]*>/, '') # strip HTML
        new_story.guid=feed_story.guid
        new_story.sourcename=feed_story.publisher.name if feed_story.publisher.name
        new_story.url=feed_story.link
        new_story.published_at = feed_story.published
        new_story.save
      end
    else
      # do nothing    
    end
  end
end

