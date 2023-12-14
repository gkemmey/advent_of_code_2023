def possibilities(springs, groups, level = 0)
  puts "    " * level + "springs=#{springs}, groups=#{groups}"
  return 1 if springs.nil? || springs.empty? || groups.empty?

  regex = groups.size > 1 ? /[#\?]{#{groups[0]}}[\.\?]{1}/ : /[#\?]{#{groups[0]}}([\.\?]{1}|$)/
  puts "    " * level + regex.inspect

  springs.chars.each_index.
                select { |i| springs[i...(i + groups[0] + 1)].match(regex) }.
                tap { |is| puts "    " * level + "indices=#{is}" }.
                collect { |i|
    puts("    " * level + "i=#{i}")
    1 * possibilities(springs[(i + groups[0] + 1)..-1], groups[1..-1], level + 1).
      tap { |p| puts("    " * level + "i=#{i} -- possiblities=#{p}") }
  }.sum
end

# -------- parsing --------

def parse_readings(input)
  input.lines(chomp: true).collect { |line|
    springs, groups = line.split(" ")

    groups = groups.split(",").map(&:to_i)

    [springs, groups]
  }
end

# -------- main --------

example = DATA.read
fail unless [1, 4, 1, 1, 4, 10] ==
              parse_readings(example)[1..1].
                collect { |springs, groups|
                  possibilities(springs, groups)
                }.tap { pp _1 }

fail unless [1, 16384, 1, 16, 2500, 506250] ==
              parse_readings(example).
                map { |springs, groups_of_damaged|
                  unfold(springs, groups_of_damaged)
                }.
                collect { |springs, groups_of_damaged|
                  possibilities(springs, groups_of_damaged)
                }

fail unless 7307 == parse_readings(File.read("./input.txt")).
                      collect { |springs, groups_of_damaged|
                        possibilities(springs, groups_of_damaged)
                      }.
                      sum

__END__
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
