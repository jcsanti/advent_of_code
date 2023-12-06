require_relative "../lib/callable_base.rb"

module Day03
  class Base < CallableBase
    class PartNumber < Data.define(:x, :y, :value); end
    class PartSymbol < Data.define(:x, :y); end

    def call
      build_coordinates
      compute_score
    end

    private

    def build_coordinates
      lines.each.with_index do |line, x|
        groups = line.split("").slice_when do |before, after|
          next if before == "." && after == "."
          next if stringified_int?(before) && stringified_int?(after)

          true
        end.to_a

        y = 0
        groups.each do |group|
          first_char = group.first

          if first_char.match?(symbol_matcher)
            part_symbols_by_x[x] ||= []
            part_symbols_by_x[x] << PartSymbol.new(x:, y:)
          elsif stringified_int?(group.first)
            part_numbers_by_x[x] ||= []
            part_numbers_by_x[x] << PartNumber.new(x:, y:, value: group.join)
          end

          y += group.length
        end
      end
    end

    def compute_score
      raise NotImplementedError
    end

    def symbol_matcher
      raise NotImplementedError
    end

    def stringified_int?(value)
      value.to_i.to_s == value
    end

    def part_numbers_by_x
      @part_numbers_by_x ||= {}
    end

    def part_symbols_by_x
      @part_symbols_by_x ||= {}
    end
  end

  class Part1 < Base
    private

    def compute_score
      part_numbers_by_x.sum do |x, part_numbers|
        part_numbers.sum do |part_number|
          next 0 unless adjacent_with_symbols?(part_number, x)

          part_number.value.to_i
        end
      end
    end

    def symbol_matcher
      /(?!\.)[[:punct:]]/
    end

    def adjacent_with_symbols?(part_number, x)
      y_candidates(x).any? do |y|
        Range.new(
          part_number.y - 1,
          part_number.y + part_number.value.length
        ).include?(y)
      end
    end

    def y_candidates(x)
      [
        *part_symbols_by_x[x - 1],
        *part_symbols_by_x[x],
        *part_symbols_by_x[x + 1]
      ].map(&:y).uniq
    end
  end

  class Part2 < Base
    private

    def compute_score
      part_symbols_by_x.sum do |x, part_symbols|
        part_symbols.sum do |part_symbol|
          adjacent_numbers = number_candidates(x).lazy.filter do |candidate|
            Range.new(
              candidate.y - 1,
              candidate.y + candidate.value.length
            ).include?(part_symbol.y)
          end.first(3)

          next 0 unless adjacent_numbers.length == 2

          adjacent_numbers.map(&:value.to_proc >> :to_i.to_proc).inject(&:*)
        end
      end
    end

    def symbol_matcher
      /\*/
    end

    def number_candidates(x)
      [
        *part_numbers_by_x[x - 1],
        *part_numbers_by_x[x],
        *part_numbers_by_x[x + 1]
      ]
    end
  end
end

puts Day03::Part1.call
puts Day03::Part2.call
