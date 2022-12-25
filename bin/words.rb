#!/usr/bin/env ruby

require 'json'
require 'fileutils'

# refs = {}
# words = File.read('./Collins Scrabble Words (2019).txt').split("\r\n")

# words.each{|w| 
#   refs[w.length] = {} if refs[w.length].nil?
#   sorted = w.split('').sort().join('')
#   refs[w.length][sorted] = [] if refs[w.length][sorted].nil?
#   refs[w.length][sorted].push(w)
# }
# File.write("scrabble_refs.json", refs.to_json)
# puts words.length
refs = JSON.parse(File.read("./scrabble_refs.json"))
dic = {}

ns_to_load = (2..6).to_a
ns_to_load.each{|n|
  fn = "scrabble_dic_#{n}.json"
  dic[n] = JSON.parse(File.read(fn)) if File.exists?(fn)
  puts "loaded #{fn}"
}

ns_to_parse = (7..10).to_a
# ns_to_parse = [7]
ns_to_parse.each{|n_main|
# refs.each{|k,v|
  k = n_main
  v = refs[k.to_s]
  puts "#{k}: #{v.length}"
  dic[k] = {} if dic[k].nil?
  v.each{|sorted_main,unused|
    puts "#{k} -- #{sorted_main}"
    dic[k][sorted_main] = {} if dic[k][sorted_main].nil?
    (2..(k-1)).to_a.reverse.each{|k_below|
      dic[k][sorted_main][k_below] = [] if dic[k][sorted_main][k_below].nil?
      dic[k_below].each_with_index{|kv,index|
        unless dic[k][sorted_main][k_below].include? index
          copy_main = sorted_main
          copy_below = kv[0]
          while (copy_below.length>0 && copy_main.include?(copy_below[0])) do
            copy_main = copy_main.sub(copy_below[0],'')
            copy_below = copy_below[1..copy_below.length]
          end
          dic[k][sorted_main][k_below].push(index) if copy_below.length==0
          kv[1].each{|ref_below_n,ref_below_refs|
            dic[k][sorted_main][ref_below_n] = [] if dic[k][sorted_main][ref_below_n].nil?
            ref_below_refs.each{|new_index| 
              dic[k][sorted_main][ref_below_n].push(new_index) unless dic[k][sorted_main][ref_below_n].include? new_index
            }
          }
        end
      }
    }
  }
  File.write("scrabble_dic_#{k}.json", dic[k].to_json)
  puts "Finished parsing #{k}"
}
