# -*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'json'

class UNVoteScrape
  def initialize(url)
    @url = url
    @reslist = Array.new
  end

  # Gets a list of resolutions
  def reslist
    html = Nokogiri::HTML(open(@url))
    content = html.css("div#content-left")
    content.css("tr").each do |r|
      td = r.css("td")[0]
      if td
        out = td.text.strip
        if (out.include? " A") || (out.include? " B") || (out.include? " A-B")
        else
          @reslist.push(out)
        end
      end
    end

    scraperes
  end

  # Scrape the details for each resolution
  def scraperes
    outarray = Array.new
    @reslist.each do |r|
      reshash = Hash.new
      if r.include? ">"
        r.gsub!(">", "")
      end

      url = "http://unbisnet.un.org:8080/ipac20/ipac.jsp?profile=voting&index=.VM&term=" + r.gsub!("/", "").downcase!
      html = Nokogiri::HTML(open(url))
      flag = 0
    
      # Go through each field
      html.css("tr").each do |t|
        field = t.css('td[width="1%"]').text
        if (field != "") && (field != nil) && !(field.include? "Add Copy to MyList") && !(field.strip.empty?)
          
          # Save data
          if field.strip == "UN Resolution Symbol: "
            flag = 1
            reshash[field] = t.css('td[width="99%"]').text
          elsif (field.strip == "Detailed Voting: ") && (flag == 1)
            votehash = Hash.new
            value = t.css('td[width="99%"]')
            value.css("td").each do |v|
               sval = v.text.split(" ", 2)
               if (sval[0] == "Y") && (sval[1].length < 50)
                 votehash[sval[1]] = sval[0]
               elsif (sval[0] == "N") && (sval[1].length < 50)
                 votehash[sval[1]] = sval[0]
               elsif (sval[0] == "A") && (sval[1].length < 50)
                 votehash[sval[1]] = sval[0]
               end
            end

            reshash[field] = votehash
          elsif flag == 1
            reshash[field] = t.css('td[width="99%"]').text
          end
        end
      end
      
      outarray.push(reshash)
    end
    puts JSON.pretty_generate(outarray)
  end
end

