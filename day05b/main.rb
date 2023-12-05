class MapEntry
  def initialize(destination_start, source_start, length)
    @destination_start, @source_start, @length = destination_start, source_start, length
  end

  def affects?(other)
    (range.cover?(other) || other.cover?(range) || overlaps?(other))
  end

  def destination_ranges(other)
    if range.cover?(other)
      [(other.min + change)...(other.max + 1 + change)]

    elsif other.cover?(range)
      [
        other.min...(range.min),
        (range.min + change)...(range.max + 1 + change),
        (range.max + 1)...(other.max + 1)
      ]

    elsif overlaps?(other)
      if overhangs_right?(other)
        [
          other.min...(range.min),
          (range.min + change)...(other.max + 1 + change)
        ]
      else # overhangs_left?(other)
        [
          (other.min + change)...(range.max + 1 + change),
          (range.max + 1)...(other.max + 1)
        ]
      end

    else
      fail
    end
  end

  private

    attr_reader :destination_start, :source_start, :length

    def range
      @range ||= (source_start...(source_start + length))
    end

    def change
      destination_start - source_start
    end

    def overlaps?(other)
      range.cover?(other.min) || other.cover?(range.min)
    end

    def overhangs_right?(other)
      # range:    |----|    |--------|
      # other: |----|       |----|
      range.min >= other.min && range.max > other.max
    end

    def overhangs_left?(other)
      # range: |----|       |--------|
      # other:    |----|             |----|
      range.min <= other.min && range.max < other.max
    end
end

class Map
  def initialize(entries)
    @entries = entries
  end

  def destination_ranges(source_ranges)
    source_ranges.
      flat_map { |sr|
        entries.reduce([sr]) { |memo, entry|
          memo.flat_map { |m| sr.cover?(m) && entry.affects?(m) ? entry.destination_ranges(m) : m }
        }
      }.
      uniq.
      reject { |r| r.size.zero? }
  end

  private

    attr_reader :entries
end

class SeedRanges
  def self.combine_ranges(ranges)
    intervals = ranges.map { |r| [r.min, r.max] }

    intervals.sort.each_with_object([]) { |(min, max), memo|
      if memo.empty? || min > memo.last[1] + 1
        memo << [min, max]
      elsif max > memo.last[1] + 1
        memo.last[1] = max
      end
    }.collect { |(min, max)| min...(max + 1) }
  end

  attr_reader :ranges

  def initialize(ranges)
    @ranges = ranges
  end

  def location_ranges(maps)
    maps.reduce(ranges.dup) { |memo, map| SeedRanges.combine_ranges(map.destination_ranges(memo)) }
  end

  def minimum_location(maps)
    location_ranges(maps).collect(&:min).min
  end
end

# -------- parsing --------

def parse(input)
  seed_ranges = parse_seed_ranges(input.lines.first)
  maps = []

  input.lines[1..-1].each do |line|
    if line.chomp.end_with?("map:")
      maps << []
    elsif line.start_with?(/\d/)
      maps.last << line.chomp
    end
  end

  maps.map! { |lines| parse_map(lines) }

  return seed_ranges, maps
end

def parse_seed_ranges(line)
  ranges = line.scan(/\d+/).map(&:to_i).each_slice(2).collect { |(start, length)| start...(start + length) }
  SeedRanges.new(ranges)
end

def parse_map(lines)
  entries = lines.each_with_object([]) { |line, memo|
    destination_start, source_start, length = line.scan(/\d+/).map(&:to_i)
    memo << MapEntry.new(destination_start, source_start, length)
  }

  Map.new(entries)
end

# -------- main --------

seed_ranges, maps = parse(DATA.read)
fail unless 46 == seed_ranges.minimum_location(maps)

seed_ranges, maps = parse(File.read("./input.txt"))
fail unless 60568880 == seed_ranges.minimum_location(maps).tap { |answer| puts(answer) }

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
