require_relative "../lib/read_input.rb"

include ReadInput

##
# Part 1
puts lines.sum { |line| line.scan(/\d/).values_at(0, -1).join.to_i }

##
# Part 2
digits_dictionary = {
  "one"   => "1",
  "two"   => "2",
  "three" => "3",
  "four"  => "4",
  "five"  => "5",
  "six"   => "6",
  "seven" => "7",
  "eight" => "8",
  "nine"  => "9"
}

stringified_digits_matcher = Regexp.union(*digits_dictionary.keys)

catch_all_matcher = Regexp.union(
  /(\d)/,
  Regexp.new("(?=(#{stringified_digits_matcher.source}))")
)

puts(
  lines.sum do |line|
    candidates = line.scan(catch_all_matcher).flatten.compact

    normalized_bounds = candidates.values_at(0, -1).map do |str|
      str.gsub(stringified_digits_matcher, digits_dictionary)
    end

    normalized_bounds.join.to_i
  end
)
