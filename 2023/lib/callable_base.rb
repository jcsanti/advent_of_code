require_relative "./read_input.rb"

class CallableBase
  class << self
    def call(...)
      new(...).call
    end
  end

  include ReadInput
end
