require "matrix"

class String
  def green
    "\e[32m#{self}\e[0m".bold
  end

  def bold
    "\e[1m#{self}\e[22m"
  end
end

UP = 0
RIGHT = 1
DOWN = 2
LEFT = 3

Beam = Struct.new(:tiles) do
  def done!
    @done = true
  end

  def done?
    !!@done
  end

  def loops?
    tiles.uniq.size < tiles.size
  end

  def head
    tiles.last
  end

  def point
    Vector[head[0], head[1]]
  end

  def heading
    head[2]
  end

  def up?;    heading == UP;    end
  def right?; heading == RIGHT; end
  def down?;  heading == DOWN;  end
  def left?;  heading == LEFT;  end

  def split(dir_a, dir_b)
    [dir_a, dir_b].map { |dir| Beam.new([Vector[*point, dir]]) }
  end
end

def max_energized(contraption)
  max_i = contraption.size - 1
  max_j = contraption[0].size - 1

  [
    Vector[0, 0, RIGHT],
    Vector[0, 0, DOWN],

    *(1...(max_j)).collect { |j| Vector[0, j, DOWN] },

    Vector[0, max_j, LEFT],
    Vector[0, max_j, DOWN],

    *(1...(max_i)).collect { |i| Vector[i, max_j, LEFT] },

    Vector[max_i, max_j, LEFT],
    Vector[max_i, max_j, UP],

    *(1...(max_j)).collect { |j| Vector[max_i, j, UP] },

    Vector[max_i, 0, RIGHT],
    Vector[max_i, 0, UP],

    *(1...(max_i)).collect { |i| Vector[i, 0, RIGHT] },
  ].collect { |start| energized(contraption, start) }.max
end

def energized(contraption, start = Vector[0, 0, RIGHT])
  energized = {}
  queue = [Beam.new([start])]
  splits = Set.new

  until queue.empty? do
    beam = queue.shift

    until beam.done? || beam.loops? do
      energized[beam.point] ||= Set.new
      energized[beam.point] << beam.heading

      # puts "=========== #{beam.head} ========="
      # pp_contraption(energized, contraption)

      if should_split?(beam, splits, contraption)
        split(beam, queue, splits, contraption) unless splits.include?(beam.point)
        beam.done!
      else
        progress(beam, contraption)
      end
    end
  end

  # pp energized
  # pp_contraption(energized, contraption)
  energized.keys.count
end

def should_split?(beam, splits, contraption)
  case tvalue(beam.point, contraption)
    when "|"
      beam.right? || beam.left?
    when "-"
      beam.up? || beam.down?
    else
      false
  end
end

def split(beam, queue, splits, contraption)
  case tvalue(beam.point, contraption)
    when "|"
      splits << beam.point
      beam.split(UP, DOWN).each { |b| queue << b }
    when "-"
      splits << beam.point
      beam.split(RIGHT, LEFT).each { |b| queue << b }
    else
      fail
  end
end

def should_progress?(point, heading, contraption)
  return point[0] > 0                              if heading == UP
  return point[1] < contraption[point[0]].size - 1 if heading == RIGHT
  return point[0] < contraption.size - 1           if heading == DOWN
  return point[1] > 0                              if heading == LEFT

  false
end

def progress(beam, contraption)
  heading = case [tvalue(beam.point, contraption), beam.heading]
              when ["/", UP]     then RIGHT
              when ["/", RIGHT]  then UP
              when ["/", DOWN]   then LEFT
              when ["/", LEFT]   then DOWN
              when ["\\", UP]    then LEFT
              when ["\\", RIGHT] then DOWN
              when ["\\", DOWN]  then RIGHT
              when ["\\", LEFT]  then UP
              else                    beam.heading
            end

  if should_progress?(beam.point, heading, contraption)
    beam.tiles << {
                    UP    => Vector[-1,  0, UP],
                    RIGHT => Vector[ 0,  1, RIGHT],
                    DOWN  => Vector[ 1,  0, DOWN],
                    LEFT  => Vector[ 0, -1, LEFT]
                  }[heading] + Vector[*beam.point, 0]
  else
    beam.done!
  end
end

def tvalue(point, contraption)
  contraption[point[0]][point[1]]
end

def pp_contraption(energized, contraption)
  puts(
    contraption.collect.with_index { |row, i|
      row.collect.with_index { |tile, j|
        if tile == "."
          if (directions = energized[Vector[i, j]])
            if directions.count > 1
              "#{directions.count}".green
            else
              { UP => "^", RIGHT => ">", DOWN => "v", LEFT => "<" }[directions.first].green
            end
          else
            tile
          end
        else
          energized.key?(Vector[i, j]) ? tile.green : tile
        end
      }.join(" ")
    }.join("\n")
  )
end

def parse_contraption(input)
  input.lines(chomp: true).collect { |l| l.chars.to_a }
end

example = DATA.read
fail unless 46 == energized(parse_contraption(example))
fail unless 7543 == energized(parse_contraption(File.read("./input.txt")))

fail unless 51 == max_energized(parse_contraption(example))
fail unless 8231 == max_energized(parse_contraption(File.read("./input.txt"))).tap { |answer| puts(answer) }


__END__
.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....
