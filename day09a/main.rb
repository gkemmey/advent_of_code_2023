class History
  def initialize(inputs)
    @inputs = inputs
    determine_differences
  end

  def next
    [*@differences.collect(&:last), @inputs.last].reduce { |memo, n| memo + n }
  end

  def determine_differences
    @differences = [@inputs.each_cons(2).map { |a, b| b - a }]

    loop do
      break if @differences.last&.all?(&:zero?)
      @differences << @differences.last.each_cons(2).map { |a, b| b - a }
    end
  end
end

def parse_histories(input)
  input.lines(chomp: true).collect { |l| History.new(l.scan(/-?\d+/).map(&:to_i)) }
end


# -------- main --------

fail unless [18, 28, 68] == parse_histories(DATA.read).collect(&:next)

fail unless 1666172641 == parse_histories(File.read("./input.txt")).collect(&:next).sum.tap { |answer| puts(answer) }

__END__
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
