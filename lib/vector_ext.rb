class Vector
  attr_accessor :x, :y, :z
  def initialize(x = nil, y = nil, z = nil)
    @x,@y,@z = x,y,z
  end

  # def +(vector)
  #   return Vector.new(@x+vector.x,)@y+vector.y)
  # end

  def self.[](x = nil, y = nil, z=nil)
    return Vector.new(x,y,z)
  end
end