require "pry-byebug"

# input = [
#   "start-A",
#   "start-b",
#   "A-c",
#   "A-b",
#   "b-d",
#   "A-end",
#   "b-end",
# ]

# input = [
#   "dc-end",
#   "HN-start",
#   "start-kj",
#   "dc-start",
#   "dc-HN",
#   "LN-dc",
#   "HN-end",
#   "kj-sa",
#   "kj-HN",
#   "kj-dc",
# ]

# input = [
#   "fs-end",
#   "he-DX",
#   "fs-he",
#   "start-DX",
#   "pj-DX",
#   "end-zg",
#   "zg-sl",
#   "zg-pj",
#   "pj-he",
#   "RW-he",
#   "fs-DX",
#   "pj-RW",
#   "zg-RW",
#   "start-pj",
#   "he-WI",
#   "zg-he",
#   "pj-fs",
#   "start-RW",
# ]

# actual puzzle
input = [
  "xx-end",
  "EG-xx",
  "iy-FP",
  "iy-qc",
  "AB-end",
  "yi-KG",
  "KG-xx",
  "start-LS",
  "qe-FP",
  "qc-AB",
  "yi-start",
  "AB-iy",
  "FP-start",
  "iy-LS",
  "yi-LS",
  "xx-AB",
  "end-KG",
  "iy-KG",
  "qc-KG",
  "FP-xx",
  "LS-qc",
  "FP-yi",
]

reverse = ->(str) { str.split("-").reverse.join("-") }

input.map! do |str|
  if str.match?(/start$/) || str.match?(/^end/)
    reverse.call(str)
  else
    str
  end
end

start_connections = input.filter { |i| i.match?(/^start/) }
end_connections = input.filter { |i| i.match?(/end$/) }

intermediate_connections = input - start_connections - end_connections
intermediate_connections |= intermediate_connections.map(&reverse)

further_connections = intermediate_connections + end_connections

# binding.pry

path_start_matcher = /^[a-zA-Z,]+/
path_end_matcher = /[a-zA-Z,]+$/

join_paths =
  lambda do |combination|
    path_1 = combination.first
    path_2 = combination.last

    [
      [
        path_1.scan(path_start_matcher),
        path_1.scan(path_end_matcher),
      ].flatten.join(","),
      path_2.scan(path_end_matcher),
    ].join("-")
  end

full_paths = []

generate_full_paths =
  lambda do |connections|
    paths =
      connections
        .flat_map do |connection|
          joined_paths =
            [connection]
              .product(further_connections)
              .reject do |combination|
                first_path = combination.first
                last_path = combination.last

                first_path.scan(path_end_matcher) != last_path.scan(path_start_matcher)
              end
              .map(&join_paths)
        end

    paths.delete_if do |path|
      # binding.pry
      (path.match?(/^start[a-zA-Z,-]+end$/) && full_paths << path) ||
        path
          .split(/-|,/)
          .tally
          .any? do |point, count|
            point.downcase == point && count > 1
          end
    end

    if paths.empty?
      full_paths.map! { |path| path.sub("-", ",") }
      break
    else
      generate_full_paths.call(paths)
    end
  end

generate_full_paths.call(start_connections)

puts full_paths.sort
puts "(count: #{full_paths.length})"
