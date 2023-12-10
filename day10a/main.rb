
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
    steps = 0

    loop do
      pp at
      pp "starting at #{at}, #{map[at[0]][at[1]]}"
      direction, next_at = move(direction, map[at[0]][at[1]], at[0], at[1])
      pp "moved to #{at}, #{map[at[0]][at[1]]}"
      steps += 1
      break if (next_at == at).tap { puts "BREAKING" if _1 }
      at = next_at
      # break if ["S", "."].include?(map[at[0]][at[1]]).tap { puts "BREAKING" if _1 }
    end

    longest = steps if longest.nil? || longest < steps
  end

  ((longest + 1) / 2).floor
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

fail unless 8 == walk_from_start(*parse_start_and_map(DATA.read))

puts walk_from_start(*parse_start_and_map(File.read("./input.txt")))

__END__
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
