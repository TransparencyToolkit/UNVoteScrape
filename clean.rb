require 'json'
require 'date'

class Clean
  def initialize(input)
    @input = JSON.parse(input)
  end

  def clean
    outarray = Array.new
    @input.each do |i|
      outhash = Hash.new
      i.each do |k, v|
        if k.include? "Link To:"
        else
          key = k.split(":")
          if k.include? "Voting Summary"
            stext = v.split(",")
            shash = Hash.new
            stext.each do |s|
              sarray = s.split(": ")
              shash[sarray[0].lstrip] = sarray[1]
            end
            v = shash
          elsif k.include? "Vote Date"
            v = DateTime.parse(v)
          end
          if v.is_a? String
            v.gsub!("'", "")
          elsif v.is_a? Hash
            tmphash = Hash.new
            v.each do |a, b|
              save = a.dup
              if a.include? "'"
                save.gsub!("'", "")
              end
              tmphash[save] = b
            end
            v = Hash.new
            v = tmphash
          end
          outhash[key[0]] = v
        end
      end
      outarray.push(outhash)
    end
    puts JSON.pretty_generate(outarray)
  end
end

