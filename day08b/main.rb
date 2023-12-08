class Map
  attr_reader :entries, :movements, :starts

  def initialize(movements, entries)
    @movements = movements

    @starts = []
    @entries = {}
    entries.each do |e|
      @entries[e.id] = e
      @starts << e if e.id.end_with?("A")
    end
  end

  # def steps_to_zzz
  #   ats = starts.dup
  #   steps = 0

  #   movements.chars.cycle.each { |direction|
  #     return steps if ats.all? { |a| a.id.end_with?("Z") }

  #     ats.map! { |at| entries[ direction == "L" ? at.left : at.right ] }

  #     exit if previous.key?(ats.collect(&:id))
  #     previous[ats.collect(&:id)] = true

  #     steps += 1
  #   }
  # end

  def steps_to_all_zzz
    starts.map { |start| steps_to_zzz(start) }
  end

  def steps_to_zzz(start)
    at = start
    intervals = []
    steps = 0

    movements.chars.cycle.each { |direction|
      if at.id.end_with?("Z")
        intervals << steps
        return intervals if intervals.size == 3
        steps = 0
      end

      at = entries[ direction == "L" ? at.left : at.right ]
      steps += 1
    }
  end
end

# class Node
#   attr_reader :id, :left, :right

#   def initialize(id, left, right)
#     @id, @left, @right = id, left, right
#   end

#   def eql?(other)
#     self.class == other.class && id == other.id && left == other.left && right == other.right
#   end
#   alias == eql?

#   def hash
#     id.hash ^ left.hash ^ right.hash
#   end
# end

Entry = Data.define(:id, :left, :right)

# -------- parsing --------

def parse_map(input)
  movements = input.lines(chomp: true).first

  entries = input.lines(chomp: true)[2..-1].each_with_object([]) { |line, memo|
    id, left, right = line.scan(/[A-Z\d]{3}/)
    memo << Entry.new(id, left, right)
  }

  Map.new(movements, entries)
end

# -------- main --------

# fail unless 6 == parse_map(DATA.read).steps_to_zzz

pp parse_map(DATA.read).steps_to_all_zzz

map = parse_map(File.read("./input.txt"))
pp map.steps_to_all_zzz

intervals = map.steps_to_all_zzz.collect(&:first)
max = intervals.max

binding.irb

__END__
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
