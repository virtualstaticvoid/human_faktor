class HeatMapColorSupport
  
  @@color_from = Colorist::Color.from_string('blue')
  @@color_to = Colorist::Color.from_string('red')
  @@color_table = @@color_from.gradient_to(@@color_to, 100)
  
  def self.color_for(value)
    value = 1 if value <= 0
    index = (Math.log(value) * 20).round(0)
    @@color_table[index] || @@color_to
  end
  
  def self.color_table
    @@color_table
  end
  
end

