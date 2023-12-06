class Record
  def initialize(time, distance)
    @time, @distance = time, distance
  end

  def number_of_ways_to_best
    0.upto(time).count { |t_held| t_held * (time - t_held) > distance }
  end

  private

    attr_reader :time, :distance
end

def parse_times(line)
  line.gsub(/\s+/, '').scan(/\d+/).map(&:to_i)
end

alias parse_distances parse_times

def parse_records(input)
  parse_times(input.lines[0]).zip(parse_distances(input.lines[1])).collect { |(t, d)| Record.new(t, d) }
end

# -------- main --------

fail unless [71503] == parse_records(DATA.read).collect(&:number_of_ways_to_best)

fail unless 28360140 == parse_records(File.read("./input.txt")).
                          collect(&:number_of_ways_to_best).
                          inject(:*).
                          tap { |answer| puts(answer) }

__END__
Time:      7  15   30
Distance:  9  40  200
