# frozen_string_literal: true

require_relative "../lib/callable_base.rb"
require "debug"

module Day01
  class Part1 < CallableBase
    def call
      left_list  = []
      right_list = []

      lines.each do |line|
        left, right = line.split(/[[:space:]]+/)
        left_list << left.to_i
        right_list << right.to_i
      end

      left_list.sort.zip(right_list.sort).sum { |left, right| (left - right).abs }
    end
  end

  class Part2 < CallableBase
    def call
      left_list  = []
      right_list = []

      lines.each do |line|
        left, right = line.split(/[[:space:]]+/)
        left_list << left.to_i
        right_list << right.to_i
      end

      right_count = right_list.tally

      left_list.sum { |left| left * (right_count[left] || 0) }
    end
  end
end

puts Day01::Part1.call
puts Day01::Part2.call
