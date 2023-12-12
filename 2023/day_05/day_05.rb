require_relative "../lib/callable_base.rb"

module Day05
  class Base < CallableBase
    def call
      seeds = lines.first.scan(/\d+/).map(&:to_i)

      lines[1..].grep_v(/:$/).slice_before(/\A$/).each do |mappings|
        seeds.map! do |seed|
          result = mappings[1..].map do |mapping|
            dest, src, length = mapping.split(/\s+/).map(&:to_i)
            diff = seed - src

            next seed if diff < 0 || diff > length
            break dest + diff
          end

          result.is_a?(Integer) ? result : result.last
        end
      end

      seeds.min
    end
  end

  class Part1 < Base; end
end

puts Day05::Part1.call
