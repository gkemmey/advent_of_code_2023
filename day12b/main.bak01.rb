
def possibilities(springs, groups_of_damaged, start = 0, mid_group = false, level = 0)
  springs = springs.dup
  groups_of_damaged = groups_of_damaged.dup

  puts "    " * level + "springs=#{springs}, groups_of_damaged=#{groups_of_damaged}, start=#{start}, mid_group=#{mid_group}"

  # count = 0

  springs[start..].each.with_index(start) do |s, i|
    puts "    " * (level + 1) + "s=#{s}, i=#{i}"
    case s
      when "."
        if mid_group
          return 0 unless groups_of_damaged[0]&.zero?

          mid_group = false
          groups_of_damaged.shift

          # if groups_of_damaged.empty?
          #   puts "    " * (level + 1) + "incrementing because this . ended the group"
          #   count += 1
          # end
        end

      when "#"
        return 0 if groups_of_damaged.empty? || groups_of_damaged[0].zero?
        mid_group = true
        groups_of_damaged[0] -= 1

      when "?"
        count = 0
        springs[i] = "#"
        count += possibilities(springs, groups_of_damaged, i, mid_group, level + 1)
        springs[i] = "."
        count += possibilities(springs, groups_of_damaged, i, mid_group, level + 1)
        puts "    " * (level + 1) + "returning early because we've done the counting"
        return count
      else
        fail
    end
  end

  # puts "    " * (level + 1) + "groups_of_damaged=#{groups_of_damaged} at the end"
  # if groups_of_damaged.empty? || groups_of_damaged == [0]
  #   puts "    " * (level + 1) + "incrementing because the string is done and groups is empty"
  #   count += 1
  # end

  if groups_of_damaged.empty? || groups_of_damaged == [0]
    puts "    " * (level + 1) + "returning  because we finished the string and used all the groups"
    return 1
  else
    return 0
  end
end

fail unless 2 == possibilities(%w(? ?), [1])
fail unless 1 == possibilities(%w(? ? ? . # # #), [1, 1, 3])
fail unless 4 == possibilities(%w(. ? ? . . ? ? . . . ? # # .), [1, 1, 3])
fail unless 1 == possibilities(%w(? # ? # ? # ? # ? # ? # ? # ?), [1, 3, 1, 6])
fail unless 1 == possibilities(%w(? ? ? ? . # . . . # . . .), [4, 1, 1])
fail unless 4 == possibilities(%w(? ? ? ? . # # # # # # . . # # # # # .), [1, 6, 5])
fail unless 10 == possibilities(%w(? # # # ? ? ? ? ? ? ? ?), [3, 2, 1])
