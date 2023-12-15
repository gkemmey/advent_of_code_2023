def lhash(string)
  string.chars.reduce(0) { |memo, c|
    (memo + c.ord) * 17 % 256
  }
end

def parse_instructions(input)
  input.chomp.split(",")
end


fail unless 52 == lhash("HASH")
fail unless 1320 == parse_instructions(DATA.read).collect { |i| lhash(i) }.sum

puts parse_instructions(File.read("./input.txt")).collect { |i| lhash(i) }.sum

__END__
rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
