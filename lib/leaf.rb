class Leaf
  attr_reader :x, :y, :color
  def initialize(x, y, color = Gosu::Color.rgba(0, 255, 0, 200))
    @origin_x, @origin_y = x, y
    @x, @y, @color = x, y, color

    @fall_speed = 0.5..0.75
    @born = Gosu.milliseconds
    @scaler = 60
    @amplifier = 3
    @fall_amplifier = 5
  end

  def draw
    Gosu.draw_rect(@x-7, @y-4, 8, 8, @color)
  end

  def update
    @y+=(Math.cos(Gosu.milliseconds-@born / @scaler) * @fall_amplifier).abs
    @x+=((Math.sin((Gosu.milliseconds-@born) / @scaler)) * @amplifier)
    @color.alpha = dynamic_from_distance

    died
  end

  def dynamic_from_distance
    total = Gosu.distance($window.width, $window.height, @origin_x, @origin_y)
    travel= Gosu.distance($window.width, $window.height, @x, @y)

    alpha = ((total / travel) * 100.0) * (255.0 / 100.0)
    alpha = 255 if alpha > 255

    return alpha
  end

  def died
    if @y > $window.height || @color.alpha <= 0
      @died = true
      $window.leaves.delete(self)
    end
  end
end