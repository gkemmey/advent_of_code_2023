class Reading
  def initialize(springs, damaged_groups)
    @springs, @damaged_groups = springs, damaged_groups
  end

  def possible_arrangements
    regex = /\.*#{damaged_groups.collect { |n| "\#{#{n}}" }.join("\\.+")}\.*/

    arrangements_regardless_of_groupings.
      reject { |a| a.count("#") > damaged_groups.sum }.
      select { |a| a.join.match?(regex) }.
      size
  end

  private

    attr_reader :springs, :damaged_groups

    def arrangements_regardless_of_groupings
      question_mark_indices = springs.each_index.select { |i| springs[i] == "?" }

      [".", "#"].repeated_permutation(question_mark_indices.count).each_with_object([]) { |substitutions, memo|
        memo << springs.dup

        question_mark_indices.each_with_index do |qi, si|
          memo.last[qi] = substitutions[si]
        end
      }
    end
end

def parse_readings(input)
  input.lines(chomp: true).collect { |line|
    reading, damaged_groups = line.split(" ")

    damaged_groups = damaged_groups.split(",").map(&:to_i)

    Reading.new(reading.chars, damaged_groups)
  }
end

fail unless [1, 4, 1, 1, 4, 10] == parse_readings(DATA.read).collect(&:possible_arrangements)

parse_readings(File.read("./input.txt")).collect(&:possible_arrangements).sum.tap { |answer| puts(answer) }

__END__
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1
