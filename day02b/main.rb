Revelation = Struct.new(:red, :green, :blue, keyword_init: true)
Result = Struct.new(:red, :green, :blue, keyword_init: true) do
  def power
    red * green * blue
  end
end

Game = Struct.new(:id, :revelations) do
  def minimum
    Result.new(red:  revelations.collect(&:red).  compact.max || 0,
              green: revelations.collect(&:green).compact.max || 0,
              blue:  revelations.collect(&:blue). compact.max || 0)
  end
end

def parse_revelations(string)
  string.split("; ").map { |part|
    Revelation.new(**(part.scan(/(\d+) (red|blue|green)/).map { |(n, color)| [color, n.to_i] }.to_h))
  }
end

def parse_game(line)
  id, revelations = line.match(/^Game (\d+): (.*)$/).to_a[1..-1]
  Game.new(id.to_i, parse_revelations(revelations))
end

def minimums(game_log)
  games = game_log.lines(chomp: true).map { |l| parse_game(l) }
  games.collect(&:minimum)
end

# -------- main --------

fail unless [
              { red: 4, green: 2, blue: 6 },
              { red: 1, green: 3, blue: 4 },
              { red: 20, green: 13, blue: 6 },
              { red: 14, green: 3, blue: 15 },
              { red: 6, green: 3, blue: 2 }
            ].map { |r| Result.new(**r) } == minimums(DATA.read)

puts minimums(File.read("./input.txt")).collect(&:power).sum

__END__
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
