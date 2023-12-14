def find_reflection(pattern)
  # puts "===================="
  # pp pattern
  axes = pattern.size.then { |s| (s / 2.0).ceil.upto(s - 1).flat_map { |n| [n, s - n] }.uniq }
  # pp axes

  row = axes.find { |a|
    # puts "checking row=#{a}"
    above = a - 1
    below = a

    mismatched = false
    loop do
      # puts "checking above=#{above}, below=#{below}"
      mismatched = pattern[above] != pattern[below]
      break if mismatched

      above -= 1
      below += 1

      break if above < 0 || below >= pattern.size
    end

    !mismatched
  }

  return [:row, row] if row

  transposed = pattern.transpose
  # puts "--------------------"
  # pp transposed
  axes = transposed.size.then { |s| (s / 2.0).ceil.upto(s - 1).flat_map { |n| [n, s - n] }.uniq }
  # pp axes

  column = axes.find { |a|
    # puts "checking column=#{a}"
    left = a - 1
    right = a

    mismatched = false
    loop do
      # puts "checking left=#{left}, right=#{right}"
      mismatched = transposed[left] != transposed[right]
      break if mismatched

      left -= 1
      right += 1

      break if left < 0 || right >= transposed.size
    end

    !mismatched
  }

  fail unless column

  return [:column, column]
end

def patterns(input)
  input.
    lines(chomp: true).
    chunk { |l| !l.empty? }.
    select(&:first).
    collect { |(_, lines)| lines.map(&:chars) }
end

def score(answer)
  answer.reduce(0) { |memo, (t, n)| memo + (t == :row ? 100 : 1) * n }
end

example = DATA.read
answer = patterns(example).map { |p| find_reflection(p) }
fail unless [[:column, 5], [:row, 4]] == answer
fail unless 405 == score(answer)

fail unless 30487 == score(patterns(File.read("./input.txt")).map { |p| find_reflection(p) }).tap { |answer| puts(answer) }

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
