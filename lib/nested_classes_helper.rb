module NestedClassesHelper
  def nested_classes(object = self)
    object.constants.collect { |c| object.const_get(c) }.select { |m| m.instance_of?(Class) }
  end
end
