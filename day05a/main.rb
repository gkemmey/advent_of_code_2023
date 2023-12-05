ConversionRange = Struct.new(:destination_start, :source_start, :length) do
  def cover?(source)
    (source_start...(source_start + length)).cover?(source)
  end

  def convert(source)
    destination_start + (source - source_start)
  end
end

Map = Struct.new(:conversion_ranges) do
  def convert(source)
    conversion_ranges.find { |cr| cr.cover?(source) }&.convert(source) || source
  end
end

def parse_map(lines)
  conversion_ranges = lines.each_with_object([]) { |line, memo|
    destination_start, source_start, length = line.scan(/\d+/).map(&:to_i)
    memo << ConversionRange.new(destination_start, source_start, length)
  }

  Map.new(conversion_ranges)
end

def parse_seeds(line)
  line.scan(/\d+/).map(&:to_i)
end

def parse(input)
  seeds = parse_seeds(input.lines.first)
  maps = []

  input.lines[1..-1].each do |line|
    if line.chomp.end_with?("map:")
      maps << []
    elsif line.start_with?(/\d/)
      maps.last << line.chomp
    end
  end

  maps.map! { |lines| parse_map(lines) }

  return seeds, maps
end

def locations(seeds, maps)
  seeds.collect { |s| maps.reduce(s) { |memo, map| map.convert(memo) } }
end

# -------- main --------

seeds, maps = parse(DATA.read)
fail unless [82, 43, 86, 35] == locations(seeds, maps)

seeds, maps = parse(File.read("./input.txt"))
puts locations(seeds, maps).min

__END__
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
