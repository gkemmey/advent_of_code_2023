class Game
  def self.number_of_games_required_to_score(games)
    copies = [1] * games.size

    games.each_with_index do |game, i|
      ((i + 1)..(i + game.matches)).each do |j|
        copies[j] += copies[i]
      end
    end

    copies.sum
  end

  def initialize(winning_numbers, player_numbers)
    @winning_numbers, @player_numbers = winning_numbers, player_numbers
  end

  def matches
    (winning_numbers & player_numbers).size
  end

  def score
    return 0 if matches.zero?
    2 ** (matches - 1)
  end

  private

    attr_reader :player_numbers, :winning_numbers
end

def parse_games(input)
  input.lines.collect { |line|
    Game.new(*line.gsub(/Card\s+\d+:\s+/, '').split("|").map { |part| part.scan(/\d+/).map(&:to_i) })
  }
end

example_games = parse_games(DATA.read)
fail unless [8, 2, 2, 1, 0, 0]  == example_games.collect(&:score)
fail unless 30 == Game.number_of_games_required_to_score(example_games)

puts Game.number_of_games_required_to_score(parse_games(File.read("./input.txt")))

__END__
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
