require_relative "../lib/callable_base.rb"

module Day02
  class Base < CallableBase
    COLORS = {
      "red"   => 12,
      "green" => 13,
      "blue"  => 14
    }

    COUNT_MATCHER = /(\d+)[[:space:]]*(#{Regexp.union(*COLORS.keys).source})/

    SET_DELIMITER = ";"

    private

    def to_color_count
      lambda do |set|
        set.scan(COUNT_MATCHER).to_h(&:reverse).transform_values(&:to_i)
      end
    end
  end

  class Part1 < Base
    ID_MATCHER = /^Game[[:space:]]*(\d+)/

    def call
      lines.sum do |line|
        next 0 if count_exceeded?(line)

        id(line)
      end
    end

    private

    def count_exceeded?(line)
      line.split(SET_DELIMITER)
          .detect do |set|
            counts = to_color_count.call(set)

            COLORS.merge(counts) do |_color, max_count, count|
              max_count - count
            end.values.any?(&:negative?)
          end
    end

    def id(line)
      line.match(ID_MATCHER)[1].to_i
    end
  end

  class Part2 < Base
    def call
      lines.sum do |line|
        line.split(SET_DELIMITER)
            .map(&to_color_count)
            .inject({}) do |hash, other|
              hash.merge(other) do |_color, count_1, count_2|
                [count_1.to_i, count_2.to_i].max
              end
            end.values.inject(&:*)
      end
    end
  end
end

puts Day02::Part1.call
puts Day02::Part2.call
