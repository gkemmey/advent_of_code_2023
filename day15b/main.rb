def lhash(string)
  string.chars.reduce(0) { |memo, c|
    (memo + c.ord) * 17 % 256
  }
end

def arrange_boxes(instructions)
  boxes = Array.new(256) { {} }

  instructions.each do |instruction|
    label, operation, length = instruction.match(/^([[:alpha:]]+)([-=])(\d+)?$/)[1..-1]
    length = length.to_i

    box = boxes[lhash(label)]

    if    operation == "="    then box[label] = length
    elsif operation == "-"    then box.delete(label)
    end

    # puts "after #{instruction}"
    # pp_boxes(boxes)
  end

  boxes
end

def focusing_power(boxes)
  boxes.each.with_index.sum { |box, i|
    box.each.with_index.sum { |(label, length), j|
      (i + 1) * (j + 1) * length
    }
  }
end

def parse_instructions(input)
  input.chomp.split(",")
end

def pp_boxes(boxes)
  boxes.each_with_index do |box, i|
    next if box.empty?

    contents = box.collect { |label, length| "[#{label} #{length}]" }
    puts "box #{i}: #{contents.join(" ")}"
  end
end

fail unless 52 == lhash("HASH")

example = DATA.read
fail unless 1320 == parse_instructions(example).collect { |i| lhash(i) }.sum
fail unless 145 == parse_instructions(example).
                     then { |instructions| arrange_boxes(instructions) }.
                     then { |boxes| focusing_power(boxes) }

puts parse_instructions(File.read("./input.txt")).
       then { |instructions| arrange_boxes(instructions) }.
       then { |boxes| focusing_power(boxes) }

__END__
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
