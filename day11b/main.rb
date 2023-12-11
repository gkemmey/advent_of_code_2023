require 'yaml'

def expandables(reading)
  expandable_rows = []
  expandable_columns = []

  reading.each.with_index do |row, i|
    expandable_rows << i if row.none? { |v| v == "#" }
  end

  reading.transpose.each.with_index do |column, j|
    expandable_columns << j if column.none? { |v| v == "#" }
  end

  return expandable_rows, expandable_columns
end

def galaxy_pairs(reading)
  galaxies = reading.each.with_index.with_object([]) { |(row, i), memo|
               row.each.with_index do |cell, j|
                 memo << [i, j] if cell == "#"
               end
             }
  galaxies.combination(2).to_a
end

def distance(galaxy_a, galaxy_b, expandable_rows, expandable_columns, expansion:)
  # puts "distance galaxy_a=#{galaxy_a}, galaxy_b=#{galaxy_b}"
  # puts "normally distance = #{(galaxy_a[0] - galaxy_b[0]).abs + (galaxy_a[1] - galaxy_b[1]).abs}"

  expandable_rows_crossed =
    expandable_rows.count { |i|
      ((galaxy_a[0] + 1)...galaxy_b[0]).include?(i) || ((galaxy_b[0] + 1)...galaxy_a[0]).include?(i)
    }

  expandable_columns_crossed =
    expandable_columns.count { |j|
      ((galaxy_a[1] + 1)...galaxy_b[1]).include?(j) || ((galaxy_b[1] + 1)...galaxy_a[1]).include?(j)
    }

  # puts "found expandable_rows_crossed=#{expandable_rows_crossed}, expandable_columns_crossed=#{expandable_columns_crossed}"

  # (
    (galaxy_a[0] - galaxy_b[0]).abs + (galaxy_a[1] - galaxy_b[1]).abs +
    (expandable_rows_crossed + expandable_columns_crossed) * [(expansion - 1), 1].max
  # ).tap { puts "now distance =#{_1}" }
end

# -------- parsing --------

def parse_reading(input)
  input.lines(chomp: true).collect { |line| line.chars.to_a }
end

# -------- example --------

example = YAML.load(DATA.read)
reading = parse_reading(example[:input])
expandable_rows, expandable_columns = expandables(reading)

fail unless expandable_rows == [3, 7]
fail unless expandable_columns == [2, 5, 8]

fail unless 374 == galaxy_pairs(reading).map { |ga, gb| distance(ga, gb, expandable_rows, expandable_columns, expansion: 1) }.sum
fail unless 1030 == galaxy_pairs(reading).map { |ga, gb| distance(ga, gb, expandable_rows, expandable_columns, expansion: 10) }.sum
fail unless 8410 == galaxy_pairs(reading).map { |ga, gb| distance(ga, gb, expandable_rows, expandable_columns, expansion: 100) }.sum

# -------- main --------

reading = parse_reading(File.read("./input.txt"))
expandable_rows, expandable_columns = expandables(reading)

fail unless 550358864332 == galaxy_pairs(reading).
                              map { |ga, gb| distance(ga, gb, expandable_rows, expandable_columns, expansion: 1_000_000) }.
                              sum.
                              tap { |answer| puts answer }

__END__
:input: |-
  ...#......
  .......#..
  #.........
  ..........
  ......#...
  .#........
  .........#
  ..........
  .......#..
  #...#.....
:expanded: |-
  ....#........
  .........#...
  #............
  .............
  .............
  ........#....
  .#...........
  ............#
  .............
  .............
  .........#...
  #....#.......
