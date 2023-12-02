require_relative "../lib/callable_base.rb"

module Day01
  class Base < CallableBase
    DIGITS_DICTIONARY = {
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

    STRINGIFIED_DIGITS_MATCHER = Regexp.union(*DIGITS_DICTIONARY.keys)

    def call
      lines.sum do |line|
        line.scan(scan_matcher)
            .flatten
            .compact
            .values_at(0, -1)
            .join
            .gsub(STRINGIFIED_DIGITS_MATCHER, DIGITS_DICTIONARY)
            .to_i
      end
    end

    private

    def scan_matcher
      /(\d)/
    end
  end

  class Part1 < Base; end

  class Part2 < Base
    private

    def scan_matcher
      Regexp.union(
        super,
        Regexp.new("(?=(#{STRINGIFIED_DIGITS_MATCHER.source}))")
      )
    end
  end
end

puts Day01::Part1.call
puts Day01::Part2.call
