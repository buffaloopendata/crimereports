require 'open-uri'
require 'JSON'
require 'date'
require 'mongo'
include Mongo

db=MongoClient.new('localhost').db('citydata')
@coll=db['crime']

def get_tiles
  tiles=[]
  File.readlines("tiles").each do |line|
    line=line.sub("\n",'')
    rowcol=line.split(':')
    tiles.push(rowcol)
  end
  return tiles
end

def get_crime_on_date(tiles, date)
  results=[]
  crimes=[]
  for tile in tiles 
    row=tile[0]
    column=tile[1]
    obj = JSON.parse get_reports(row,column,date,date)
    results.push(obj)
  end

  for result in results
    for crime in result['crimes']
      crimes.push(crime)
    end
  end
  return crimes
end

def get_reports(row, column, start_date, end_date, incident_type_ids="100,104,98,103,99,101,170,8,97,148,9,149,15", zoom='13')
  baseurl="https://www.crimereports.com/v3/crime_reports/map/search_by_tile.json?"
  url=baseurl+"start_date=#{start_date}&end_date=#{end_date}&incident_type_ids=#{incident_type_ids}&row=#{row}&column=#{column}&zoom=#{zoom}&include_sex_offenders=false"
  return open(url,{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
end


def get_crime_for_year year
  tiles=get_tiles
  totalcrimes=[]
  for Date.new(2012, 01, 01).upto(Date.new(2012, 01, 30)) do |date|
    sleep 1.0
    crimes=get_crime_on_date(tiles,date.to_s.gsub('-','/'))
    for crime in crimes
      #push to mongo
      @coll.insert crime
    end 
  end
end
