class HeatMapColorSupport

  attr_reader :color_from
  attr_reader :color_to
  attr_reader :scale
  attr_accessor :failsafe_color
  attr_reader :max
  attr_reader :color_table

  def initialize(color_from, color_to, max, scale = 10, failsafe_color = 'black')
    @color_from = Colorist::Color.from_string(color_from)
    @color_to = Colorist::Color.from_string(color_to)
    @scale = scale
    @failsafe_color = Colorist::Color.from_string(failsafe_color)
    @max = (max <= 0) ? 1 : max
    @color_table = @color_from.gradient_to(@color_to, scale + 2)
  end
  
  def color_for(value)
    # convert to a percentage
    index = (value.to_f / @max.to_f) * @scale
    #puts ">>> max => #{@max}, value => #{value}, index => #{index}"
    @color_table[index.to_i] || @failsafe_color
  end
  
end

