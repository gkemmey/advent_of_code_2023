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

  def cyan
    "\e[36m#{self}\e[0m"
  end
end

def walk_from_start(start, map)
  longest = nil
  start_direction = nil
  finish_direction = nil

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
    current_loop = [at]

    loop do
      direction, next_at = move(direction, map[at[0]][at[1]], at[0], at[1])
      break if (next_at == at)
      current_loop << next_at
      break if ["S", "."].include?(map[at[0]][at[1]])
      at = next_at
    end

    if longest.nil? || current_loop.size > longest.size
      longest = current_loop
      start_direction = starting_direction
      finish_direction = direction
    end
  end

  return start_direction, finish_direction, longest
end

def find_contained_by_walking_the_wall_with_your_left_hand_touching(start, ploop, outside, map)
  all = (0...map.size).flat_map { |i| (0...map[i].size).collect { |j| [i, j] } }
  left = all - ploop.to_a - outside.to_a

  contained = Set.new

  k = 0
  until k >= left.size
    l = left[k]
    puts "======= checking #{l} (k=#{k}) ======="

    if adjacent_to_outside?(l[0], l[1], outside, map)
      puts "outside b/c adjacent to outside"
      outside << l
      k += 1
      next
    end

    if adjacent_to_contained?(l[0], l[1], contained, map)
      puts "contained b/c adjacent to contained"
      contained << l
      k += 1
      next
    end

    direction, at = if left_adjacent_to_pipe?(l[0], l[1], ploop, map)
                      puts "left_adjacent_to_pipe"
                      [:north, [l[0], l[1] - 1]]

                    elsif top_adjacent_to_pipe?(l[0], l[1], ploop, map)
                      puts "top_adjacent_to_pipe"
                      [:east, [l[0] - 1, l[1]]]

                    elsif right_adjacent_to_pipe?(l[0], l[1], ploop, map)
                      puts "right_adjacent_to_pipe"
                      [:south, [l[0], l[1] + 1]]

                    elsif bottom_adjacent_to_pipe?(l[0], l[1], ploop, map)
                      puts "bottom_adjacent_to_pipe"
                      [:west, [l[0] + 1, l[1]]]

                    else
                      left << left.delete_at(k)
                      next
                    end
    start_at = at
    puts "starting at direction=#{direction}, at=#{at}"

    loop do
      direction, at = move(direction, map[at[0]][at[1]], at[0], at[1])
      puts "moved to direction=#{direction}, at=#{at}"

      if at[0] == 0 && direction == :west ||
          at[0] == map.size && direction == :east ||
          at[1] == 0 && direction == :south ||
          at[1] == map[at[0]].size && direction == :north

        puts "outside b/c on edge"
        outside << l
        break
      end

      at_right = case direction
                 when :north
                   [at[0], at[1] + 1]
                 when :south
                   [at[0], at[1] - 1]
                 when :east
                   [at[0] + 1, at[1]]
                 when :north
                   [at[0] - 1, at[1]]
                 end

      if start_at == at
        puts "contained b/c i'm back to where i started"
        contained << l
        break
      end

      if outside.include?(at_right)
        puts "outside b/c to my right is outside"
        outside << l
        break
      end
    end

    k += 1
  end

  contained
end

def adjacent_to_outside?(i, j, outside, map)
  if i > 0
    return true if outside.include?([i - 1, j])
  elsif i < map.size - 1
    return true if outside.include?([i + 1, j])
  elsif j > 0
    return true if outside.include?([i, j - 1])
  elsif j < map[i].size - 1
    return true if outside.include?([i, j + 1])
  end

  return false
end

def adjacent_to_contained?(i, j, contained, map)
  if i > 0
    return true if contained.include?([i - 1, j])
  elsif i < map.size - 1
    return true if contained.include?([i + 1, j])
  elsif j > 0
    return true if contained.include?([i, j - 1])
  elsif j < map[i].size - 1
    return true if contained.include?([i, j + 1])
  end

  return false
end

def left_adjacent_to_pipe?(i, j, ploop, map)
  return false if j <= 0
  ploop.include?([i, j - 1])
end

def top_adjacent_to_pipe?(i, j, ploop, map)
  return false if i <= 0
  ploop.include?([i - 1, j])
end

def right_adjacent_to_pipe?(i, j, ploop, map)
  return false if j >= map[i].size - 1
  ploop.include?([i, j + 1])
end

def bottom_adjacent_to_pipe?(i, j, ploop, map)
  return false if i >= map.size - 1
  ploop.include?([i + 1, j])
end

def move(direction, pipe, i, j)
  puts "processing move: direction=#{direction}, pipe=#{pipe}, i=#{i}, j=#{j}"

  case [direction, pipe]
    when [:north, "|"]
      [:north, [i - 1, j]]

    when [:south, "|"]
      [:south, [i + 1, j]]

    when [:east, "-"]
      [:east, [i, j + 1]]

    when [:west, "-"]
      [:west, [i, j - 1]]

    when [:west, "L"], [:north, "L"]
      [:north, [i - 1, j]]

    when [:south, "L"], [:east, "L"]
      [:east, [i, j + 1]]

    when [:east, "J"], [:north, "J"]
      [:north, [i - 1, j]]

    when [:south, "J"], [:west, "J"]
      [:west, [i, j - 1]]

    when [:east, "7"], [:south, "7"]
      [:south, [i + 1, j]]

    when [:north, "7"], [:west, "7"]
      [:west, [i, j - 1]]

    when [:west, "F"], [:south, "F"]
      [:south, [i + 1, j]]

    when [:north, "F"], [:east, "F"]
      [:east, [i, j + 1]]

    else
      [direction, [i, j]]
  end
end

def rewrite_start(start, start_direction, finish_direction, map)
  char =
    case [start_direction, finish_direction]
      when [:north, :north], [:south, :south]
        "|"
      when [:east, :east], [:west, :west]
        "-"
      when [:east, :north], [:south, :west]
        "F"
      when [:east, :south], [:north, :west]
        "L"
      when [:west, :south], [:north, :east]
        "J"
      when [:west, :north], [:south, :east]
        "7"
      else
        fail [start_direction, finish_direction]
    end

  map[start[0]][start[1]] = char
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

def find_outside(loop, map)
  outside = Set.new

  map.each_with_index do |row, i|

    # row left-to-right
    left_most_edge = loop.select { |l| l[0] == i }.map { |l| l[1] }.min
    row.each_with_index do |cell, j|
      outside << [i, j] if left_most_edge.nil? || j < left_most_edge
    end

    # row left-to-right
    right_most_edge = loop.select { |l| l[0] == i }.map { |l| l[1] }.max
    row.reverse.each_with_index do |cell, __j__|
      j = row.size - __j__ - 1
      outside << [i, j] if right_most_edge.nil? || j > right_most_edge
    end

  end

  map.transpose.each_with_index do |column, j|

    # column top-to-bottom
    top_most_edge = loop.select { |l| l[1] == j }.map { |l| l[0] }.min
    column.each_with_index do |cell, i|
      outside << [i, j] if top_most_edge.nil? || i < top_most_edge
    end

    # column bottom-to-top
    bottom_most_edge = loop.select { |l| l[1] == j }.map { |l| l[0] }.max
    column.reverse.each_with_index do |cell, __i__|
      i = column.size - __i__ - 1
      outside << [i, j] if bottom_most_edge.nil? || i > bottom_most_edge
    end

  end

  outside
end

example = <<~TEXT
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
TEXT

_, _, loop = walk_from_start(*parse_start_and_map(example))
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
start_direction, finish_direction, loop = walk_from_start(start, map)
rewrite_start(start, start_direction, finish_direction, map)
outside = find_outside(loop, map)

puts example
contained = find_contained_by_walking_the_wall_with_your_left_hand_touching(start, loop, outside, map)

puts example
puts "==================="
puts(
  example.lines(chomp: true).map.with_index { |line, i|
    line.chars.map.with_index { |char, j|
      if loop.include?([i, j])
        char == "S" ? map[i][j].green : char.green
      # elsif contained.include?([i, j])
      #   char.blue.bold
      elsif outside.include?([i, j])
        char.red
      else
        char
      end
    }.join(" ")
  }.join("\n")
)

fail unless 4 == contained.size

example = <<~TEXT
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...
TEXT
start, map = parse_start_and_map(example)
start_direction, finish_direction, loop = walk_from_start(start, map)
rewrite_start(start, start_direction, finish_direction, map)
outside = find_outside(loop, map)

contained = find_contained_by_walking_the_wall_with_your_left_hand_touching(start, loop, outside, map)

puts example
puts "==================="
puts(
  example.lines(chomp: true).map.with_index { |line, i|
    line.chars.map.with_index { |char, j|
      if loop.include?([i, j])
        char == "S" ? map[i][j].green : char.green
      # elsif contained.include?([i, j])
      #   char.blue.bold
      elsif outside.include?([i, j])
        char.red
      else
        char
      end
    }.join(" ")
  }.join("\n")
)

fail unless 8 == contained.size

example = DATA.read
start, map = parse_start_and_map(example)
start_direction, finish_direction, loop = walk_from_start(start, map)
rewrite_start(start, start_direction, finish_direction, map)
outside = find_outside(loop, map)

contained = find_contained_by_walking_the_wall_with_your_left_hand_touching(start, loop, outside, map)

puts example
puts "==================="
puts(
  example.lines(chomp: true).map.with_index { |line, i|
    line.chars.map.with_index { |char, j|
      if loop.include?([i, j])
        char == "S" ? map[i][j].green : char.green
      # elsif contained.include?([i, j])
      #   char.blue.bold
      elsif outside.include?([i, j])
        char.red
      else
        char
      end
    }.join(" ")
  }.join("\n")
)

fail unless 10 == contained.size

example = File.read("./input.txt")
start, map = parse_start_and_map(example)
start_direction, finish_direction, loop = walk_from_start(start, map)
rewrite_start(start, start_direction, finish_direction, map)
outside = find_outside(loop, map)

contained = find_contained_by_walking_the_wall_with_your_left_hand_touching(start, loop, outside, map)

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
        char.blue.cyan
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
