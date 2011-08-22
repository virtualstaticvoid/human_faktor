class HeatMapColorSupport

  attr_reader :color_from
  attr_reader :color_to
  attr_accessor :failsafe_color
  attr_reader :min
  attr_reader :max
  attr_reader :color_table

  def initialize(color_from, color_to, min, max, failsafe_color = 'black')
    @color_from = Colorist::Color.from_string(color_from)
    @color_to = Colorist::Color.from_string(color_to)
    @failsafe_color = Colorist::Color.from_string(failsafe_color)
    @min = min
    @max = max
    @color_table = @color_from.gradient_to(@color_to, 102)
  end
  
  def color_for(value)
    # convert to a percentage
    index = ((value.to_f - @min.to_f) / (@max.to_f - @min.to_f)) * 100.0
    index = 0 if index.nan? || index.infinite?
    #puts ">>> min => #{@min}, max => #{@max}, value => #{value}, index => #{index}"
    @color_table[index.to_i] || @failsafe_color
  end

end

