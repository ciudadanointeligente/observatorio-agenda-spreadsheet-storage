#encoding: utf-8
require 'scraperwiki'
require 'nokogiri'

# Read in a page
url = "https://docs.google.com/spreadsheets/d/1QkkIRF-3Qrz-aRIxERbGbB7YHWz2-t4ix-7TEcuBNfE/pubhtml?gid=2014567304&single=true"
page = Nokogiri::HTML(open(url), nil, 'utf-8')
rows = page.xpath('//table[@class="waffle"]/tbody/tr')

# Find something on the page using css selectors
content = []
rows.collect do |r|
  content << r.xpath('td').map { |td| td.text.strip }
end

# Builds records
content.shift
content.each do |row|

  record = {
    "id" => row[0],
    "date" => row[1],
    "startDate" => row[2],
    "endDate" => row[3],
    "title" => row[4],
    "summary" => row[5],
    "last_update" => Date.today.to_s
  }

  # Save if the record doesn't exist
  if ((ScraperWiki.select("* from data where `source`='#{record['id']}'").empty?) rescue true)
    ScraperWiki.save_sqlite(["id"], record)
    puts "Adds new record " + record['id']
  else
    puts "Skipping already saved record " + record['id']
  end
end

# # An arbitrary query against the database
# ScraperWiki.select("* from data where 'name'='peter'")

# You don't have to do things with the Mechanize or ScraperWiki libraries.
# You can use whatever gems you want: https://morph.io/documentation/ruby
# All that matters is that your final data is written to an SQLite database
# called "data.sqlite" in the current working directory which has at least a table
# called "data".
