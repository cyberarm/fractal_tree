class Leaf
  attr_reader :x, :y, :color
  def initialize(x, y, color = nil)
    @origin_x, @origin_y = x, y
    color ||= a_fall_color

    @x, @y, @color = x, y, color

    @inital_alpha = color.alpha.to_f

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
    @x+=((Math.sin((Gosu.milliseconds-@born) / @scaler)) * @amplifier)
    @y+=(Math.cos(Gosu.milliseconds-@born / @scaler) * @fall_amplifier).abs
    @color.alpha = dynamic_alpha_from_distance

    die?
  end

  def a_fall_color
    list = [
      Gosu::Color.rgba(200, 255, 0, 200),
      Gosu::Color.rgba(255, 200, 0, 200),
      Gosu::Color.rgba(150, 150, 0, 200)
    ]

    list.sample
  end

  def dynamic_alpha_from_distance
    total = Gosu.distance(@origin_x, @origin_y, @origin_x, $window.height)
    travel= Gosu.distance(@x, @y, @x, $window.height)

    alpha = ((travel / total) * 100.0) * (@inital_alpha / 100.0)
    alpha = @inital_alpha if alpha > @inital_alpha

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