class Map
  attr_reader :entries, :movements

  def initialize(movements, entries)
    @movements = movements
    @entries = entries.each_with_object({}) { |e, memo| memo[e.id] = e }
  end

  def steps_to_zzz
    at = entries["AAA"]
    steps = 0

    movements.chars.cycle.each { |direction|
      return steps if at.id == "ZZZ"

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
    id, left, right = line.scan(/[A-Z]{3}/)
    memo << Entry.new(id, left, right)
  }

  Map.new(movements, entries)
end

# -------- main --------

fail unless 6 == parse_map(DATA.read).steps_to_zzz

map = parse_map(File.read("./input.txt"))
puts map.steps_to_zzz

__END__
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
