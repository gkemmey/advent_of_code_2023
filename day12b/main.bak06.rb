def possibilities(springs, groups)
  n         = springs.size
  min       = (groups.sum + groups.size - 1)

  dots = n - min
  k = groups.size + 1

  memo = {}

  puts "springs=#{springs}, groups#{groups}"
  puts "n=#{n}, min=#{min}, dots=#{dots}, k=#{k}"

  partition(dots, k).count { |part|
    # puts "part=#{part}"

    i = 0
    mk = []

    part.each_with_index.all? { |p, j|
      mk << p

      # puts "    i=#{i}, mk=#{mk} j=#{j}, p=#{p}"
      if !memo[mk].nil?
        # puts "    seen it before! got #{memo[mk]}"
        next memo[mk]
      end

      memo[mk] = -> {
        if j > 0 && j <= groups.size
          # puts "        checking group=#{groups[j - 1]} (at #{j - 1})"
          # puts "        checking substring=#{springs[i...(i + groups[j - 1])]} at #{i...(i + groups[j - 1])}"
          return false unless springs[i...(i + groups[j - 1])].all? { |s| s == "#" || s == "?" }
          i += groups[j - 1]

          unless j == groups.size
            return false unless springs[i] == "." || springs[i] == "?"
            i += 1
          end
        end

        springs[i...(i + p)].all? { |s| s == "." || s == "?" }.tap { i += p }
      }.call
    }#.tap { puts("======================================================================== #{part}") if _1 }
  }
end

def partition(m, k)
  return [m] if k == 1

  (0..m).flat_map { |n|
    partition(m - n, k - 1).collect { |p| [n, p].flatten }
  }
end

# -------- parsing --------

def parse_readings(input)
  input.lines(chomp: true).collect { |line|
    springs, groups = line.split(" ")

    springs = springs.chars.to_a
    groups = groups.split(",").map(&:to_i)

    [springs, groups]
  }
end

def unfold(springs, groups_of_damaged)
  return [
    ([springs.join] * 5).join("?").chars,
    groups_of_damaged * 5
  ]
end

def squish(springs)
  springs.join.gsub(/^\.+/, '').gsub(/\.+$/, '').gsub(/\.+/, '.').chars.to_a
end

# -------- main --------

example = DATA.read
fail unless [1, 4, 1, 1, 4, 10] ==
              parse_readings(example).
                map { |springs, groups|
                  [squish(springs), groups]
                }.
                collect { |springs, groups|
                  possibilities(springs, groups)
                }

fail unless [1, 16384, 1, 16, 2500, 506250] ==
              parse_readings(example).
                map { |springs, groups_of_damaged|
                  unfold(springs, groups_of_damaged)
                }.
                map { |springs, groups|
                  [squish(springs), groups]
                }.
                collect { |springs, groups_of_damaged|
                  possibilities(springs, groups_of_damaged)
                }

__END__
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
