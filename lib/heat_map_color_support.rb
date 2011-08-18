class HeatMapColorSupport

  def initialize(color_from, color_to, min, max)
    @color_from = Colorist::Color.from_string(color_from)
    @color_to = Colorist::Color.from_string(color_to)
    @min = min.to_i
    @max = max.to_i
    @color_table = @color_from.gradient_to(@color_to, 1 + (@max - @min))
  end
  
  def color_for(value)
    return @color_from if value <= @min
    return @color_to if value >= @max
    @color_table[value]
  end
  
end

