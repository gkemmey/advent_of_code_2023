def digitize(value)
  case value
    when "0", "zero"  then "0"
    when "1", "one"   then "1"
    when "2", "two"   then "2"
    when "3", "three" then "3"
    when "4", "four"  then "4"
    when "5", "five"  then "5"
    when "6", "six"   then "6"
    when "7", "seven" then "7"
    when "8", "eight" then "8"
    when "9", "nine"  then "9"
    else                   nil
  end
end

def calibration_value(line)
  first, *, last = line.scan(/(?=(\d|zero|one|two|three|four|five|six|seven|eight|nine))/).flatten
  first, last = digitize(first), digitize(last)

  (last ? "#{first}#{last}" : "#{first}#{first}").to_i
end

def calibration_values(document)
  document.lines.map { |l| calibration_value(l) }
end

fail unless [29, 83, 13, 24, 42, 14, 76, 71] == calibration_values(DATA.read)

puts calibration_values(File.read("./input.txt")).sum

__END__
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
sevensrncljm5zmvvrtthreejjd85twonepvj
