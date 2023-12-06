require_relative "../lib/callable_base.rb"

module Day04
  class Base < CallableBase
    SPACES = /[[:space:]]+/
    CARD_PREFIX = /^Card#{SPACES}\d+:/

    private

    def find_winning_numbers(line)
      winning, mine = line.sub(CARD_PREFIX, "")
                          .split("|")
                          .map { |numbers| numbers.strip.split(SPACES) }

      winning & mine
    end
  end

  class Part1 < Base
    def call
      lines.sum do |line|
        my_wins = find_winning_numbers(line)

        next 0 if my_wins.empty?

        2**(my_wins.length - 1)
      end
    end
  end

  class Part2 < Base
    def call
      lines.each.with_index do |line, original|
        cards[original] += 1

        my_wins = find_winning_numbers(line)

        next if my_wins.empty?

        copies(original, my_wins).each { |copy| cards[copy] += cards[original] }
      end

      cards.values.sum
    end

    private

    def copies(original, my_wins)
      ((original + 1)..(original + my_wins.length))
    end

    def cards
      @cards ||= Hash.new(0)
    end
  end
end

puts Day04::Part1.call
puts Day04::Part2.call
