def grid(input)
  input.lines(chomp: true).collect { |line| line.chars }
end

def calc_load(grid)
  loads = []

  # pp grid.transpose

  grid.transpose.each do |column|
    open = 0
    column.each_with_index do |cell, i|
      if cell == "#"
        open = i + 1
      elsif cell == "O"
        loads << open
        open += 1
      end
    end
    # pp loads
  end

  loads.map { |l| grid.size - l }.sum
end

fail unless 136 == calc_load(grid(DATA.read))
fail unless 105208 == calc_load(grid(File.read("./input.txt"))).tap { pp _1 }

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
