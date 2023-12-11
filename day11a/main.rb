require 'yaml'

def expand_reading(reading)
  i = 0
  while i < reading.size - 1
    row = reading[i]

    if row.none? { |v| v == "#" }
      reading.insert(i, row.dup)
      i += 1
    end

    i += 1
  end

  j = 0
  while j < reading[0].size - 1
    column = reading.map { |row| row[j] }

    if column.none? { |v| v == "#" }
      reading.each_with_index { |row, i| row.insert(j, column[i]) }
      j += 1
    end

    j += 1
  end
end

def galaxy_pairs(reading)
  galaxies = reading.each.with_index.with_object([]) { |(row, i), memo|
               row.each.with_index do |cell, j|
                 memo << [i, j] if cell == "#"
               end
             }
  galaxies.combination(2).to_a
end

def distance(galaxy_a, galaxy_b)
  (galaxy_a[0] - galaxy_b[0]).abs + (galaxy_a[1] - galaxy_b[1]).abs
end

# -------- parsing --------

def parse_reading(input)
  input.lines(chomp: true).collect { |line| line.chars.to_a }
end

# -------- example --------

example = YAML.load(DATA.read)
reading = parse_reading(example[:input])
expand_reading(reading)

fail unless reading == parse_reading(example[:expanded])
fail unless 374 == galaxy_pairs(reading).map { |ga, gb| distance(ga, gb) }.sum

# -------- main --------

reading = parse_reading(File.read("./input.txt"))
expand_reading(reading)

fail unless 9965032 == galaxy_pairs(reading).map { |ga, gb| distance(ga, gb) }.sum.tap { |answer| puts(answer) }

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
