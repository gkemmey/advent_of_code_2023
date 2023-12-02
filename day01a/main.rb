def calibration_value(line)
  first, *, last = line.scan(/\d/)
  (last ? "#{first}#{last}" : "#{first}#{first}").to_i
end

def calibration_values(document)
  document.lines.map { |l| calibration_value(l) }
end

fail unless [12, 38, 15, 77] == calibration_values(DATA.read)

puts calibration_values(File.read("./input.txt")).sum

__END__
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
