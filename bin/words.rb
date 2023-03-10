#!/usr/bin/env ruby

require 'json'
require 'fileutils'

# refs = {}
# # words = File.read('./Collins Scrabble Words (2019).txt').split("\r\n")
# words = File.read('./list2p2gfreq.txt').split("\r\n")
# puts "Number of lines: #{words.length}; head: #{words[0..9]}"
# words = words.uniq
# puts "Number of unique words: #{words.length}; head: #{words[0..9]}"
# words = words.reject{|w|w.length<2}
# puts "Number of unique words of 2+ letters: #{words.length}; head: #{words[0..9]}"

# words.each{|w| 
#   refs[w.length] = {} if refs[w.length].nil?
#   sorted = w.split('').sort().join('').upcase
#   refs[w.length][sorted] = [] if refs[w.length][sorted].nil?
#   refs[w.length][sorted].push(w.upcase)
# }
# puts refs.map{|k,v| "#{k}: #{v.length}; head #{v.keys[0..2]} > #{v.values[0..2]}"}
# # File.write("scrabble_refs.json", refs.to_json)
# File.write("gfreq_refs.json", refs.to_json)
# return

# If already parsed
# refs = JSON.parse(File.read("./scrabble_refs.json"))
refs = JSON.parse(File.read("./gfreq_refs.json"))
dic = {}

# ns_to_load = []
ns_to_load = (2..4).to_a
ns_to_load.each{|n|
  # fn = "scrabble_dic_#{n}.json"
  fn = "gfreq_dic_#{n}.json"
  dic[n] = JSON.parse(File.read(fn)) if File.exists?(fn)
  puts "loaded #{fn}"
}

ns_to_parse = (5..7).to_a
ns_to_parse.each{|n_main|
  k = n_main
  v = refs[k.to_s]
  puts "#{k}: #{v.length}"
  dic[k] = {} if dic[k].nil?
  v.each_with_index{|keyvalue,i|
    sorted_main = keyvalue[0]
    puts "#{k} -- #{sorted_main} -- #{i}/#{v.length} (#{(100*i.to_f/v.length.to_f).to_i}%)"
    dic[k][sorted_main] = {} if dic[k][sorted_main].nil?
    reg = /^#{sorted_main.split('').join("?")}?$/
    (2..(k-1)).to_a.reverse.each{|k_below|
      dic[k][sorted_main][k_below] = [] if dic[k][sorted_main][k_below].nil?
      dic[k_below].each_with_index{|kv,index|
        unless dic[k][sorted_main][k_below].include? index
          sorted_below = kv[0]
          # copy_main = sorted_main
          # copy_below = kv[0]
          # while (copy_below.length>0 && copy_main.include?(copy_below[0])) do
          #   copy_main = copy_main.sub(copy_below[0],'')
          #   copy_below = copy_below[1..copy_below.length]
          # end
          # dic[k][sorted_main][k_below].push(index) if copy_below.length==0
          if sorted_below.match(reg)
            dic[k][sorted_main][k_below].push(index) 
            match_set = kv[1]
            match_set.each{|match_set_k,match_set_refs|
              dic[k][sorted_main][match_set_k] = [] if dic[k][sorted_main][match_set_k].nil?
              match_set_refs.each{|new_index|
                dic[k][sorted_main][match_set_k].push(new_index) unless dic[k][sorted_main][match_set_k].include? new_index
              }
            }
          end
        end
      }
    }
  }
  # File.write("scrabble_dic_#{k}.json", dic[k].to_json)
  File.write("gfreq_dic_#{k}.json", dic[k].to_json)
  puts "Finished parsing #{k}"
}
