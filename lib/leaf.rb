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
    @color.alpha = dynamic_alpha_from_distance

    die?
  end

  def dynamic_alpha_from_distance
    total = Gosu.distance(@origin_x, @origin_y, @origin_x, $window.height)
    travel= Gosu.distance(@x, @y, @x, $window.height)

    alpha = ((travel / total) * 100.0) * (255.0 / 100.0)
    alpha = 255 if alpha > 255

    # puts "total: #{total}, travel: #{travel}, total / travel: #{((travel / total) * 100).round(2)}% - #{self.object_id}" if @y > $window.height || alpha <= 10
    return alpha
  end

  def die?
    if @y > $window.height || @color.alpha <= 0
      @died = true
      $window.leaves.delete(self)
    end
  end
end