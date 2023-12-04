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
    @_part_numbers ||= numeric_entries.select { |n| symbol_adjacent?(n) }
  end

  def gear_ratios
    schematic.each.with_index.with_object([]) { |(row, i), memo|
      row.each.with_index do |entry, j|
        next unless entry == "*"

        adjacent_part_numbers = adjacent_part_numbers(i, j)
        next unless adjacent_part_numbers.size == 2

        memo << adjacent_part_numbers[0].value * adjacent_part_numbers[1].value
      end
    }
  end

  def part_numbers
    _part_numbers.collect(&:value)
  end

  private

    attr_reader :numeric_entries, :_part_numbers, :schematic

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

    def adjacent_cells(row, column)
      ([-1, 0, +1].repeated_permutation(2).to_a - [[0, 0]]).
        map { |(r, c)| [row + r, column + c] }.
        reject { |(r, c)| r < 0 || r >= schematic.length || c < 0 || c >= schematic[0].length }
    end

    def adjacent_entries(row, column)
      adjacent_cells(row, column).collect { |(r, c)| schematic[r][c] }
    end

    def adjacent_part_numbers(row, column)
      adjacent_cells = adjacent_cells(row, column)
      _part_numbers.select { |n| (adjacent_cells & n.cells).any? }
    end
end

example_schematic = Schematic.parse(DATA.read)
fail unless   4361 == example_schematic.part_numbers.sum
fail unless 467835 == example_schematic.gear_ratios.sum

puts Schematic.parse(File.read("./input.txt")).gear_ratios.sum

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
