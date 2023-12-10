class String
  def green
    "\e[32m#{self}\e[0m"
  end

  def red
    "\e[31m#{self}\e[0m"
  end

  def blue
    "\e[34m#{self}\e[0m"
  end

  def bold
    "\e[1m#{self}\e[22m"
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

def find_contained_and_outside(loop, map)
  contained = Set.new
  outside = Set.new

  map.each_with_index do |row, i|
    crossings = []

    # row left-to-right
    row.each_with_index do |cell, j|
      if loop.include?([i, j])
        crossings.unshift(cell) if cell == "|"
        crossings << cell       if %w(F L).include?(cell)
        crossings.pop           if %w(7 J).include?(cell)
      else
        contained << [i, j] if crossings.size.odd?
      end
    end

    crossings = []

    # row right-to-left
    row.reverse.each_with_index do |cell, __j__|
      j = row.size - __j__ - 1

      if loop.include?([i, j])
        crossings.unshift(cell) if cell == "|"
        crossings << cell       if %w(J 7).include?(cell)
        crossings.pop           if %w(L F).include?(cell)
      else
        contained << [i, j] if crossings.size.odd?
      end
    end
  end

  map.transpose.each_with_index do |column, j|
    crossings = []

    # column top-to-bottom
    column.each_with_index do |cell, i|
      if loop.include?([i, j])
        crossings.unshift(cell) if cell == "-"
        crossings << cell       if %w(F 7 -).include?(cell)
        crossings.pop           if %w(L J).include?(cell)
      else
        contained << [i, j] if crossings.size.odd?
      end
    end

    crossings = []

    # column bottom-to-top
    column.reverse.each_with_index do |cell, __i__|
      i = column.size - __i__ - 1

      if loop.include?([i, j])
        crossings.unshift(cell) if cell == "-"
        crossings << cell       if %w(L J -).include?(cell)
        crossings.pop           if %w(F 7).include?(cell)
      else
        contained << [i, j] if crossings.size.odd?
      end
    end
  end

  return contained, outside
end

# def find_outside(loop, map)
#   outside = Set.new

#   map.each_with_index do |row, i|

#     # row left-to-right
#     left_most_edge = loop.select { |l| l[0] == i }.map { |l| l[1] }.min
#     row.each_with_index do |cell, j|
#       outside << [i, j] if left_most_edge.nil? || j < left_most_edge
#     end

#     # row left-to-right
#     right_most_edge = loop.select { |l| l[0] == i }.map { |l| l[1] }.max
#     row.reverse.each_with_index do |cell, __j__|
#       j = row.size - __j__ - 1
#       outside << [i, j] if right_most_edge.nil? || j > right_most_edge
#     end
#   end

#   map.transpose.each_with_index do |column, j|

#     # column top-to-bottom
#     top_most_edge = loop.select { |l| l[1] == j }.map { |l| l[0] }.min
#     column.each_with_index do |cell, i|
#       outside << [i, j] if top_most_edge.nil? || i < top_most_edge
#     end

#     # column bottom-to-top
#     bottom_most_edge = loop.select { |l| l[1] == j }.map { |l| l[0] }.max
#     column.reverse.each_with_index do |cell, __i__|
#       i = column.size - __i__ - 1
#       outside << [i, j] if bottom_most_edge.nil? || i > bottom_most_edge
#     end
#   end

#   outside
# end

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
contained, outside = find_contained_and_outside(loop, map)

puts example
puts "==================="
puts(
  example.lines(chomp: true).map.with_index { |line, i|
    line.chars.map.with_index { |char, j|
      if loop.include?([i, j])
        char.green
      elsif contained.include?([i, j])
        char.blue.bold
      elsif outside.include?([i, j])
        char.red
      else
        char
      end
    }.join(" ")
  }.join("\n")
)
pp contained

fail unless 4 == contained.size

example = DATA.read
start, map = parse_start_and_map(example)
loop = walk_from_start(start, map)
contained, outside = find_contained_and_outside(loop, map)

puts example
puts "==================="
puts(
  example.lines(chomp: true).map.with_index { |line, i|
    line.chars.map.with_index { |char, j|
      if loop.include?([i, j])
        char.green
      elsif contained.include?([i, j])
        char.blue.bold
      elsif outside.include?([i, j])
        char.red
      else
        char
      end
    }.join(" ")
  }.join("\n")
)

pp contained
pp (contained - outside)
fail unless 10 == (contained - outside).size
puts "🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋🦋"

example = File.read("./input.txt")
start, map = parse_start_and_map(example)
loop = walk_from_start(start, map)
contained, outside = find_contained_and_outside(loop, map)

puts example
puts "==================="
puts(
  example.lines(chomp: true).map.with_index { |line, i|
    line.chars.map.with_index { |char, j|
      if loop.include?([i, j])
        char.green
      elsif outside.include?([i, j])
        char.red
      elsif contained.include?([i, j])
        char.blue.bold
      else
        char
      end
    }.join(" ")
  }.join("\n")
)

puts contained.size

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
