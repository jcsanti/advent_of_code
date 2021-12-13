class Octopus
  def initialize(index, row_index, state, matrix)
    @index     = index
    @row_index = row_index
    @state     = state
    @matrix    = matrix
  end

  attr_reader :index, :row_index, :state, :matrix

  def increment!
    @state += 1 if can_increment?
  end

  def should_flash?
    @state == 10
  end

  def flash!
    if should_flash?
      display("flash") do
        @state = 11
        increment_adjacent_octopuses!
      end
    end
  end

  def reset!
    @state = 0 if just_flashed?
  end

  def resetted?
    @state.zero?
  end

  private

  def display(title)
    matrix.display(title) do
      yield
    end
  end

  def just_flashed?
    @state == 11
  end

  def can_increment?
    !should_flash? && !just_flashed?
  end

  def increment_adjacent_octopuses!
    matrix
      .as_rows
      .slice(row_index - 1, row_index, row_index + 1)
      .values
      .each do |row|
        adjacent_octopuses =
          row.filter_map do |octopus|
            next if octopus == self
            next unless [index - 1, index, index + 1].include?(octopus.index)

            octopus
          end

        adjacent_octopuses.each(&:increment!)
      end
  end
end

class OctopusMatrix
  def initialize(grid, delay: true)
    @grid  = grid
    @delay = delay

    @octopuses = []

    @processed_step = 0
    @flashes_count  = 0

    display("original grid") do
      build!
    end
  end

  attr_reader :processed_step

  def simultaneous_flash_found?
    @octopuses.all?(&:resetted?)
  end

  def advance!
    increment!
    flash!
    reset_octopuses!
    update_flashes_count!

    @processed_step += 1

    display("finished step ##{@processed_step}")
  end

  def as_rows
    @octopuses
      .group_by(&:row_index)
      .transform_values do |octopuses|
        octopuses.sort_by(&:index)
      end
  end

  def display(title = "current_state")
    yield if block_given?

    sleep(0.5) if @delay

    puts(<<~TEXT)
      \n#{title}:
      #{displayable_grid}
      (flashes_count => #{@flashes_count})
    TEXT
  end

  private

  def build!
    @grid.each.with_index do |row, row_index|
      @octopuses |=
        row.map.with_index do |octopus_state, octopus_index|
          Octopus.new(octopus_index, row_index, octopus_state, self)
        end
    end
  end

  def increment!
    display("increment") do
      @octopuses.each(&:increment!)
    end
  end

  def flash!
    until @octopuses.none?(&:should_flash?)
      @octopuses.each(&:flash!)
    end
  end

  def reset_octopuses!
    @octopuses.map(&:reset!)
  end

  def update_flashes_count!
    @flashes_count += @octopuses.count(&:resetted?)
  end

  def displayable_grid
    as_rows
      .values
      .map(&to_displayable_line)
      .join("\n")
  end

  def to_displayable_line
    lambda do |octopuses|
      octopuses.map(&:state).join("")
    end
  end
end

# grid = [
#   [1, 1, 1, 1, 1],
#   [1, 9, 9, 9, 1],
#   [1, 9, 1, 9, 1],
#   [1, 9, 9, 9, 1],
#   [1, 1, 1, 1, 1],
# ]
#
# octopus_matrix = OctopusMatrix.new(grid); nil
#
# octopus_matrix.advance!
#
# grid_2 = [
#   [5, 4, 8, 3, 1, 4, 3, 2, 2, 3],
#   [2, 7, 4, 5, 8, 5, 4, 7, 1, 1],
#   [5, 2, 6, 4, 5, 5, 6, 1, 7, 3],
#   [6, 1, 4, 1, 3, 3, 6, 1, 4, 6],
#   [6, 3, 5, 7, 3, 8, 5, 4, 7, 8],
#   [4, 1, 6, 7, 5, 2, 4, 6, 4, 5],
#   [2, 1, 7, 6, 8, 4, 1, 7, 2, 1],
#   [6, 8, 8, 2, 8, 8, 1, 1, 3, 4],
#   [4, 8, 4, 6, 8, 4, 8, 5, 5, 4],
#   [5, 2, 8, 3, 7, 5, 1, 5, 2, 6],
# ]
#
# octopus_matrix = OctopusMatrix.new(grid_2, delay: false); nil
#
# 100.times { octopus_matrix.advance! }

puzzle = [
  [4, 4, 7, 2, 5, 6, 2, 2, 6, 4],
  [8, 6, 3, 1, 5, 1, 7, 8, 2, 7],
  [7, 2, 3, 2, 1, 4, 4, 1, 4, 6],
  [2, 4, 4, 7, 1, 6, 3, 8, 2, 4],
  [1, 2, 3, 5, 2, 7, 2, 6, 7, 1],
  [5, 1, 3, 3, 5, 2, 7, 1, 4, 6],
  [6, 5, 1, 1, 3, 7, 2, 4, 1, 7],
  [3, 8, 4, 1, 8, 4, 1, 6, 1, 4],
  [8, 6, 2, 1, 3, 6, 8, 7, 8, 2],
  [3, 2, 4, 6, 3, 3, 6, 6, 7, 7],
]

octopus_matrix = OctopusMatrix.new(puzzle, delay: false); nil

loop do
  octopus_matrix.advance!
  break if octopus_matrix.simultaneous_flash_found?
end

puts "\nfirst_step_with_simultaneous_flash => #{octopus_matrix.processed_step}"
