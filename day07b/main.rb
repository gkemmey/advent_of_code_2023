class Card
  PRECEDENCE = %w(J 2 3 4 5 6 7 8 9 T Q K A)

  include Comparable

  def self.wild
    Card.new("J")
  end

  attr_reader :rank

  def initialize(rank)
    @rank = rank
  end

  def <=>(other)
    PRECEDENCE.index(rank) <=> PRECEDENCE.index(other.rank)
  end

  def eql?(other)
    self.class == other.class && rank.eql?(other.rank)
  end

  def hash
    rank.hash
  end

  def to_s
    rank.to_s
  end
end

class Hand
  PRECEDENCE = %i(high_card one_pair two_pair three_of_a_kind full_house four_of_a_kind five_of_a_kind)

  include Comparable

  attr_reader :cards, :kind

  def initialize(cards)
    @cards = cards
    determine_kind
  end

  def <=>(other)
    self_p_kind = PRECEDENCE.index(kind)
    other_p_kind = PRECEDENCE.index(other.kind)

    return self_p_kind <=> other_p_kind unless self_p_kind == other_p_kind

    cards.zip(other.cards).map { |(card, other_card)| card <=> other_card }.find { |n| n != 0 } || 0
  end

  def to_s
    cards.collect(&:rank).join
  end

  private

    def determine_kind(tally = cards.tally)
      @kind = begin
        if    tally.values.sort == [5]          then :five_of_a_kind
        elsif tally.values.sort == [1, 4]       then :four_of_a_kind
        elsif tally.values.sort == [2, 3]       then :full_house
        elsif tally.values.sort == [1, 1, 3]    then :three_of_a_kind
        elsif tally.values.sort == [1, 2, 2]    then :two_pair
        elsif tally.values.sort == [1, 1, 1, 2] then :one_pair
        else                                         :high_card
        end
      end

      if (n_js = tally.delete(Card.wild))
        return if n_js == 5
        reassign_wild_cards(tally, n_js)
        determine_kind(tally)
      end
    end

    def reassign_wild_cards(tally, n_js)
      assign_to_highest_count = -> { tally[ tally.key(tally.values.max) ] += n_js }
      assign_to_highest_rank  = -> { tally[ tally.keys.max ]              += n_js }

      case kind
        when :four_of_kind, :full_house, :three_of_a_kind, :one_pair
          assign_to_highest_count.call

        when :two_pair
          n_js > 1 ? assign_to_highest_count.call : assign_to_highest_rank.call

        else
          assign_to_highest_rank.call
      end
    end
end

Bid = Struct.new(:hand, :amount)

# -------- parsing --------

def parse_hand(hand)
  Hand.new(hand.chars.map { |rank| Card.new(rank) })
end

def parse_bids(input)
  input.lines(chomp: true).collect { |line|
    hand, amount = line.split(/\s+/)

    hand = parse_hand(hand)
    amount = amount.to_i

    Bid.new(hand, amount)
  }
end

# -------- main --------

bids = parse_bids(DATA.read)
fail unless %w(32T3K KK677 T55J5 QQQJA KTJJT) == bids.sort_by(&:hand).collect(&:hand).map(&:to_s)
fail unless 5905 == bids.sort_by(&:hand).map.with_index { |bid, i| bid.amount * (i + 1) }.sum

bids = parse_bids(File.read("./input.txt"))
fail unless 247885995 == bids.sort_by(&:hand).map.with_index { |bid, i| bid.amount * (i + 1) }.sum.tap { |answer| puts(answer) }

__END__
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
