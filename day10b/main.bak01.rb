class String
  def green
    "\e[32m#{self}\e[0m"
  end
end

def walk_from_start(start, map)
  pp start
  map.each { puts _1.join }
  longest = nil

  [:north, :south, :east, :west].each do |starting_direction|
    direction = starting_direction
    at =
      case direction
        when :north
          [[start[0] - 1, 0].max, start[1]]
        when :south
          [[start[0] + 1, map.size - 1].min, start[1]]
        when :east
          [start[0], [start[1] + 1, map[0].size - 1].min]
        when :west
          [start[0], [start[1] - 1, 0].max]
      end
    puts " ================================ start =========================="
    pp starting_direction
    pp at
    current_loop = [at]

    loop do
      pp at
      pp "starting at #{at}, #{map[at[0]][at[1]]}"
      direction, next_at = move(direction, map[at[0]][at[1]], at[0], at[1])
      pp "moved to #{at}, #{map[at[0]][at[1]]}"
      break if (next_at == at).tap { puts "BREAKING" if _1 }
      current_loop << next_at
      break if ["S", "."].include?(map[at[0]][at[1]]).tap { puts "BREAKING" if _1 }
      at = next_at
    end

    longest = current_loop if longest.nil? || current_loop.size > longest.size
  end

  longest
end

def peek(direction, at, map)
  case direction
    when :north
      map[at[0] - 1][at[1]]
    when :south
      map[at[0] + 1][at[1]]
    when :east
      map[at[0]][at[1] - 1]
    when :west
      map[at[0]][at[1] + 1]
  end
end

def move(direction, pipe, i, j)
  pp "moving: #{[direction, pipe]}"

  case [direction, pipe]
    when [:north, "|"]
      [:north, [i - 1, j]]

    when [:south, "|"]
      [:south, [i + 1, j]]

    when [:east, "-"]
      [:east, [i, j + 1]]

    when [:west, "-"]
      [:west, [i, j - 1]]

    when [:west, "L"]
      [:north, [i - 1, j]]

    when [:south, "L"]
      [:east, [i, j + 1]]

    when [:east, "J"]
      [:north, [i - 1, j]]

    when [:south, "J"]
      [:west, [i, j - 1]]

    when [:east, "7"]
      [:south, [i + 1, j]]

    when [:north, "7"]
      [:west, [i, j - 1]]

    when [:west, "F"]
      [:south, [i + 1, j]]

    when [:north, "F"]
      [:east, [i, j + 1]]

    else
      [direction, [i, j]]
  end
end

def parse_start_and_map(input)
  map = input.lines(chomp: true).map { |line| line.chars }

  start = nil
  map.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      start = [i, j] if cell == "S"
    end
  end

  return start, map
end

def count_contained(loop, map)
  contained = 0

  map.each_with_index do |row, i|
    crossings = 0

    row.each_with_index do |cell, j|

      puts "checking #{[i, j]}, #{cell}"
      if loop.include?([i, j])
        puts "on loop: #{cell}"
        crossings += 1 unless cell == "-"
        puts "crossings: #{crossings}"

      elsif crossings > 0
        puts "off loop, crossings: #{crossings}"
        contained += 1 if crossings.odd?
      end

    end
  end

  contained
end

example = <<~TEXT
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
TEXT

loop = walk_from_start(*parse_start_and_map(example))
puts "🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋"
pp loop
fail unless 16 == loop.size

example = <<~TEXT
__END__
..........
.S------7.
.|F----7|.
.||OOOO||.
.||OOOO||.
.|L-7F-J|.
.|II||II|.
.L--JL--J.
..........
TEXT

start, map = parse_start_and_map(example)
loop = walk_from_start(start, map)

fail unless 4 == count_contained(loop, map).tap { pp _1 }

example = DATA.read
start, map = parse_start_and_map(example)
loop = walk_from_start(start, map)

puts example
puts "==================="
puts(
  example.lines(chomp: true).map.with_index { |line, i|
    line.chars.map.with_index { |char, j|
      if loop.include?([i, j])
        char.green
      else
        char
      end
    }.join
  }.join("\n")
)

puts "🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋"
fail unless 10 == count_contained(loop, map).tap { pp _1 }

# puts walk_from_start(*parse_start_and_map(File.read("./input.txt")))

__END__
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJIF7FJ-
L---JF-JLJIIIIFJLJJ7
|F|F-JF---7IIIL7L|7|
|FFJF7L7F-JF7IIL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
