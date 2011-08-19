class HeatMapColorSupport

  def initialize(color_from, color_to, max)
    @color_from = Colorist::Color.from_string(color_from)
    @color_to = Colorist::Color.from_string(color_to)
    @max = (max <= 0) ? 1 : max
    @color_table = @color_from.gradient_to(@color_to, 100)
  end
  
  def color_for(value)
    # convert to a percentage
    
    index = (value.to_f / @max.to_f) * 100.0
    
    puts ">>> max => #{@max}, value => #{value}, index => #{index}"
  
    @color_table[index.to_i]
  end
  
end

