intervals = [12643, 14257, 15871, 18023, 19637, 16409]

max = intervals.max
steps = max
offsets = intervals.map { |i| (i + max) % i }

loop do
  # pp steps
  # pp offsets
  break if offsets.all?(&:zero?)

  offsets = offsets.map.with_index { |o, i| (o + max) % intervals[i] }
  steps += max
end

puts steps
