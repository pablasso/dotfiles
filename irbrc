# Awesome Print
require "rubygems"
require "awesome_print"

unless IRB.version.include?('DietRB')
  IRB::Irb.class_eval do
    def output_value
      ap @context.last_value
    end
  end
else # MacRuby
  IRB.formatter = Class.new(IRB::Formatter) do
    def inspect_object(object)
      object.ai
    end
  end.new
end

# Show methods not inherited from Object
class Object
  def own_methods
    (self.methods - Object.instance_methods).sort
  end
end
