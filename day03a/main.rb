class String
  def digit?
    self == "0" || self == "1" || self == "2" || self == "3" || self == "4" ||
      self == "5" || self == "6" || self == "7" || self == "8" || self == "9"
  end
end

class Schematic
  NumericEntry = Data.define(:value, :cells)

  def self.parse(input)
    new(input.lines(chomp: true).map(&:chars))
  end

  def initialize(schematic)
    @schematic = schematic
    identify_numeric_entries
  end

  def part_numbers
    numeric_entries.select { |n| symbol_adjacent?(n) }.collect(&:value)
  end

  private

    attr_reader :numeric_entries, :schematic

    def identify_numeric_entries
      @numeric_entries = schematic.each.with_index.with_object([]) { |(row, i), memo|
        row.
          each.
          with_index.
          slice_when { |(a, i), (b, j)| a.digit? != b.digit? }.
          select { |slice| slice[0][0].digit? }.
          map { |slice|
            [slice.collect(&:first).join.to_i, slice[0][1]..slice[-1][1]]
          }.
          each do |(n, columns)|
            memo << NumericEntry.new(n, columns.collect { |c| [i, c] })
          end
      }
    end

    def digit?(entry)
      entry.match(/\d/)
    end

    def symbol_adjacent?(numeric_entry)
      numeric_entry.cells.any? { |(row, column)|
        adjacent_entries(row, column).any? { |entry| entry.match(/[\*\+\$\/\-@&=%#]/) }
      }
    end

    def adjacent_entries(row, column)
      ([-1, 0, +1].repeated_permutation(2).to_a - [[0, 0]]).
        map { |(r, c)| [row + r, column + c] }.
        reject { |(r, c)| r < 0 || r >= schematic.length || c < 0 || c >= schematic[0].length }.
        collect { |(r, c)| schematic[r][c] }
    end
end

fail unless 4361 == Schematic.parse(DATA.read).part_numbers.sum

puts Schematic.parse(File.read("./input.txt")).part_numbers.sum

__END__
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
