def solve(springs, groups_of_damaged, start = 0, mid_group = false, level = 0)
  springs = springs.dup
  groups_of_damaged = groups_of_damaged.dup

  springs[start..].each.with_index(start) do |s, i|
    case s
      when "."
        if mid_group
          return 0 unless groups_of_damaged[0]&.zero?

          mid_group = false
          groups_of_damaged.shift
        end

      when "#"
        return 0 if groups_of_damaged.empty? || groups_of_damaged[0].zero?
        mid_group = true
        groups_of_damaged[0] -= 1

      when "?"
        count = 0

        springs[i] = "#"
        count += solve(springs, groups_of_damaged, i, mid_group, level + 1)

        springs[i] = "."
        count += solve(springs, groups_of_damaged, i, mid_group, level + 1)

        return count

      else
        fail
    end
  end

  groups_of_damaged.empty? || groups_of_damaged == [0] ? 1 : 0
end

def possibilities(springs, groups_of_damaged)
  squish(springs).split(".").collect { |part|
    groups_of_damaged.sum { |group|
      solve(part.chars, [group]).tap { puts("part=#{part}, group=#{group} -- got #{_1}") }
    }
  }.inject(:*)
end

# -------- parsing --------

def parse_readings(input)
  input.lines(chomp: true).collect { |line|
    reading, groups_of_damaged = line.split(" ")

    reading = reading.chars
    groups_of_damaged = groups_of_damaged.split(",").map(&:to_i)

    [reading, groups_of_damaged]
  }
end

def squish(springs)
  springs.join.gsub(/^\.+/, '').gsub(/\.+$/, '').gsub(/\.+/, '.')
end

fail unless [1, 4, 1, 1, 4, 10] == parse_readings(DATA.read).
                                     collect { |springs, groups_of_damaged|
                                       possibilities(springs, groups_of_damaged)
                                     }.tap { pp _1 }

fail unless 7307 == parse_readings(File.read("./input.txt")).
                      collect { |springs, groups_of_damaged|
                        possibilities(springs, groups_of_damaged)
                      }.
                      sum.
                      tap { |answer| puts(answer) }

__END__
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
