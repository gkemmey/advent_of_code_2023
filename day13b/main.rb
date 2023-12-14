class Pattern
  attr_reader :grid, :t_grid

  def initialize(grid)
    @grid = grid
    @t_grid = grid.transpose
  end

  def axis_of_reflection
    @axis_of_reflection ||= row_of_reflection || column_of_reflection || fail("unable to find axis of reflection")
  end

  def repaired_axis_of_reflection
    @repaired_axis_of_reflection ||= __repaired_axis_of_reflection__
  end

  def score
    (axis_of_reflection[0] == :row ? 100 : 1) * axis_of_reflection[1]
  end

  def repaired_score
    (repaired_axis_of_reflection[0] == :row ? 100 : 1) * repaired_axis_of_reflection[1]
  end

  private

    def __repaired_axis_of_reflection__
      row = row_axes_from_middle_out(excluding: axis_of_reflection).find do |axis|
        mismatch_used = false

        reflected_row_pairs(axis).all? do |a, b|
          if mismatches_in_reflected_pair(grid[a], grid[b]) == 1 && !mismatch_used
            mismatch_used = true
            next true
          end

          grid[a] == grid[b]
        end
      end

      return [:row, row] if row

      column = column_axes_from_middle_out(excluding: axis_of_reflection).find do |axis|
        mismatch_used = false

        reflected_column_pairs(axis).all? do |a, b|
          if mismatches_in_reflected_pair(t_grid[a], t_grid[b]) == 1  && !mismatch_used
            mismatch_used = true
            next true
          end

          t_grid[a] == t_grid[b]
        end
      end

      return [:column, column] if column

      fail "unable to repair"
    end

    def row_of_reflection
      row = row_axes_from_middle_out.find { |axis|
        reflected_row_pairs(axis).all? { |a, b| grid[a] == grid[b] }
      }

      [:row, row] if row
    end

    def column_of_reflection
      column = column_axes_from_middle_out.find { |axis|
        reflected_column_pairs(axis).all? { |a, b| t_grid[a] == t_grid[b] }
      }

      [:column, column] if column
    end

    def reflected_row_pairs(axis)
      [].tap { |memo|
        above = axis - 1
        below = axis

        loop do
          break if above < 0 || below >= grid.size
          memo << [above, below]

          above -= 1
          below += 1
        end
      }
    end

    def reflected_column_pairs(axis)
      [].tap { |memo|
        above = axis - 1
        below = axis

        loop do
          break if above < 0 || below >= t_grid.size
          memo << [above, below]

          above -= 1
          below += 1
        end
      }
    end

    def row_axes_from_middle_out(excluding: nil)
      axes_from_middle_out(grid.size).tap { |axes|
        axes.delete(excluding[1]) if excluding&.[](0) == :row
      }
    end

    def column_axes_from_middle_out(excluding: nil)
      axes_from_middle_out(t_grid.size).tap { |axes|
        axes.delete(excluding[1]) if excluding&.[](0) == :column
      }
    end

    def axes_from_middle_out(size)
      (size / 2.0).ceil.upto(size - 1).flat_map { |n| [n, size - n] }.uniq
    end

    def mismatches_in_reflected_pair(a, b)
      a.zip(b).count { |a, b| a != b }
    end
end

def parse_patterns(input)
  input.
    lines(chomp: true).
    chunk { |l| !l.empty? }.
    select(&:first).
    collect { |(_, lines)| lines.map(&:chars) }.
    map { |grid| Pattern.new(grid) }
end

# -------- main --------

example = DATA.read
patterns = parse_patterns(example)

fail unless [[:column, 5], [:row, 4]] == patterns.collect(&:axis_of_reflection)
fail unless 405 == patterns.sum(&:score)

fail unless [[:row, 3], [:row, 1]] == patterns.collect(&:repaired_axis_of_reflection)
fail unless 400 == patterns.sum(&:repaired_score)

patterns = parse_patterns(File.read("./input.txt"))
fail unless 30487 == patterns.sum(&:score)
fail unless 31954 == patterns.sum(&:repaired_score).tap { |answer| puts(answer) }


__END__
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#
