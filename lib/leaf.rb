class Leaf
  attr_accessor :detached, :x, :y, :color, :dead
  def initialize(x, y, branch_is_sapling = false, color = nil)
    @origin_x, @origin_y = x, y
    color ||= a_fall_color

    @x, @y, @color = x, y, color
    @size = 1
    @max_size = 8

    @inital_alpha = color.alpha.to_f

    @dead = false
    @grown = false
    @adult = false
    @detached = false

    if branch_is_sapling
      @color= Gosu::Color.rgba(50, 200, 0, 225)
    end

    @born = Gosu.milliseconds
    @time_to_live = rand(15_000..60_000)
    @grown_time = 0.5 # 50%
    @age_time = 0.8 # 80%-50% -> 30%

    @fall_speed = 0.5..0.75
    @scaler = 60
    @amplifier = 3
    @fall_amplifier = 5
  end

  def draw
    Gosu.draw_rect(@x-((@size/2)+1), @y-(@size/2), @size, @size, @color)
  end

  def update
    grow unless @grown
    age if @grown
    fall if @detached

    die?
  end

  def grow
    @size = @max_size / ((@born + (@time_to_live * @grown_time)) / Gosu.milliseconds)

    @grown = true if Gosu.milliseconds >= @born + (@time_to_live * @grown_time)
  end

  def age
    if Gosu.milliseconds >= @born + (@time_to_live * @age_time)
      n = rand
      chance = n >= 0.005 && n <= 0.0051
      @detached = true if chance
    end
  end

  def fall
    @x+=((Math.sin((Gosu.milliseconds-@born) / @scaler)) * @amplifier)
    @y+=(Math.cos(Gosu.milliseconds-@born / @scaler) * @fall_amplifier).abs
    @color.alpha = dynamic_alpha_from_distance
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