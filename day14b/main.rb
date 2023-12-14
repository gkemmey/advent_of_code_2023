def grid(input)
  input.lines(chomp: true).collect { |line| line.chars }
end

def roll_north(grid)
  grid.transpose.each_with_index do |column, j|
    open = 0

    column.each_with_index do |cell, i|
      if cell == "#"
        open = i + 1
      elsif cell == "O"
        grid[i][j] = "."
        grid[open][j] = "O"
        open += 1
      end
    end
  end
end

def roll_south(grid)
  grid.transpose.each_with_index do |column, j|
    open = 0

    column.reverse.each_with_index do |cell, i|
      if cell == "#"
        open = i + 1
      elsif cell == "O"
        grid[grid.size - 1 - i][j] = "."
        grid[grid.size - 1 - open][j] = "O"
        open += 1
      end
    end
  end
end

def roll_west(grid)
  grid.each_with_index do |row, i|
    open = 0

    row.each_with_index do |cell, j|
      if cell == "#"
        open = j + 1
      elsif cell == "O"
        grid[i][j] = "."
        grid[i][open] = "O"
        open += 1
      end
    end
  end
end

def roll_east(grid)
  grid.each_with_index do |row, i|
    open = 0

    row.reverse.each_with_index do |cell, j|
      if cell == "#"
        open = j + 1
      elsif cell == "O"
        grid[i][grid[i].size - 1 - j] = "."
        grid[i][grid[i].size - 1 - open] = "O"
        open += 1
      end
    end
  end
end

def spin(grid)
  roll_north(grid)
  roll_west(grid)
  roll_south(grid)
  roll_east(grid)
end

def load_after_a_billion_spins(grid)
  previous = [grid.map(&:dup)]

  1.upto(1_000) do |n|
    spin(grid)

    if (pi = previous.index(grid))
      offset = pi
      mod = n - offset

      same = (1_000_000_000 - offset) % mod + offset

      return calc_load(previous[same])
    end

    previous << grid.map(&:dup)
  end

  fail "gotta be cycle"
end

def calc_load(grid)
  grid.each_with_index.sum { |row, i| row.count("O") * (grid.size - i) }
end

example = grid(DATA.read)
fail unless 64 == load_after_a_billion_spins(example)

fail unless 102943 == load_after_a_billion_spins(grid(File.read("./input.txt"))).tap { |answer| puts(answer) }

__END__
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
