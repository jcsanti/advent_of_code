# frozen_string_literal: true

module ReadInput
  def lines
    @lines ||= File.readlines(
      File.join(File.dirname(caller.first), "input.txt"),
      chomp: true
    )
  end
end
