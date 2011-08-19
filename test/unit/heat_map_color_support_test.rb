require 'test_helper'
require 'heat_map_color_support'

class HeatMapColorSupportTest < ActiveSupport::TestCase

  test 'should yield a color for each value in range' do
    helper = HeatMapColorSupport.new('blue', 'green', 10)
    helper.failsafe_color = nil # NNB: for test to work...
    
    (0..10).each do |i|
      assert helper.color_for(i)
    end
  end

end
