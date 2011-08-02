class HeatMapColorSupport
  
  @@white = Colorist::Color.from_string('white')
  @@red = Colorist::Color.from_string('red')
  @@color_table = @@white.gradient_to(@@red, 100)
  
  def self.color_for(value)
    throw :unexpected_value if value <= 0
    index = Math.log(value).round(0) * 10
    @@color_table[index]
  end
  
  def self.color_table
    @@color_table
  end
  
end

