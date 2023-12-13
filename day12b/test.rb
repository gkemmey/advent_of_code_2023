@dp = Array.new(10) { Array.new(10) }

def solve(length, gap, level = 0)
  puts "    " * level + "length=#{length}, gap=#{gap}"
  puts "    " * level + "starting"
  pp @dp
  puts "    " * level + "end starting"

  if @dp[length][gap]
    return @dp[length][gap]
  end

  return 1 if length == 0 || gap == 0
  return 0 if gap < 0

  answer = 0
  (0..gap).each { |i| answer += solve(length - 1, gap - i, level + 1) }

  @dp[length][gap] = answer
  puts "    " * level + "ending"
  pp @dp
  puts "    " * level + "end ending"
  return answer
end

def count(input)
  @dp.each_index { |i| @dp[i].each_index { |j| @dp[i][j] = nil } }

  n = input.length
  left = 1
  right = 9

  count = 0
  answer = 1

  input.chars.each_with_index { |c, i|
    puts "c=#{c}, i=#{i}"
    if c == "?"
      count += 1
    else
      right = c.to_i

      answer *= solve(count, right - left)

      left = right
      right = 9

      count = 0
    end
  }

  answer *= solve(count, right - left)

  return answer
end

# ---- main ----
# puts count("1???2")
puts count("2??43?4")
