require 'open-uri'
require 'JSON'

def get_tiles
  tiles=[]
  File.readlines("tiles").each do |line|
    line=line.sub("\n",'')
    rowcol=line.split(':')
    tiles.push(rowcol)
  end
  return tiles
end

def get_tiles_on_date(tiles, date)
  results=[]
  for tile in tiles 
    row=tile[0]
    column=tile[1]
    obj = JSON.parse get_reports(row,column,date,date)
    results.push(obj)
  end
  return results
end

def get_reports(row, column, start_date, end_date, incident_type_ids="100,104,98,103,99,101,170,8,97,148,9,149,15", zoom='13')
  baseurl="https://www.crimereports.com/v3/crime_reports/map/search_by_tile.json?"
  url=baseurl+"start_date=#{start_date}&end_date=#{end_date}&incident_type_ids=#{incident_type_ids}&row=#{row}&column=#{column}&zoom=#{zoom}&include_sex_offenders=false"
  return open(url,{ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
end

