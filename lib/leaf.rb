class Leaf
  attr_accessor :detached, :x, :y, :color, :dead, :branch_is_sapling
  def initialize(x, y, branch_is_sapling = false, color = nil)
    @origin_x, @origin_y = x, y
    color ||= a_leaf_color
    @fall_color = a_fall_color

    @x, @y, @color = x, y, color
    @size = 1
    @max_size = 8

    @inital_alpha = color.alpha.to_f

    @dead = false
    @grown = false
    @adult = false
    @detached = false
    @branch_is_sapling = branch_is_sapling

    if branch_is_sapling
      @time_to_live = rand(1_500..5_000)
      @size = 3
    end

    @born = Gosu.milliseconds
    @time_to_live ||= rand(45_000..60_000)
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
    unless @branch_is_sapling
      grow unless @grown
      age if @grown
    end
      fall if @detached

    die?
  end

  def grow
    @size = @max_size / ((@born + (@time_to_live * @grown_time)) / Gosu.milliseconds)
    if Gosu.milliseconds >= @born + (@time_to_live * @grown_time)
      @grown = true
    end
  end

  def age
    factor = ((Gosu.milliseconds - (@born + (@time_to_live * @grown_time))) / (@born + (@time_to_live * @age_time))) # Working, maybe?
    factor = factor.clamp(0, 1.0)
    fade_to_fall_color(factor)

    if Gosu.milliseconds >= @born + (@time_to_live * @age_time)
      # raise "Factor was #{factor.round(4)}, not 1.0" if factor != 1.0
      n = rand
      chance = n >= (0.05) && n <= 0.051
      chance = true if @branch_is_sapling
      @detached = true if chance
    end
  end

  def fall
    @x+=((Math.sin((Gosu.milliseconds-@born) / @scaler)) * @amplifier)
    @y+=(Math.cos(Gosu.milliseconds-@born / @scaler) * @fall_amplifier).abs
    @color.alpha = dynamic_alpha_from_distance
  end

  def fade_to_fall_color(factor)
    @color = Gosu::Color.rgba(
      @color.red   + factor * (@fall_color.red  - @color.red  ),
      @color.green + factor * (@fall_color.green- @color.green),
      @color.blue  + factor * (@fall_color.blue - @color.blue),
      @color.alpha
    )
  end

  def a_fall_color
    list = [
      Gosu::Color.rgba(200, 255, 0, 200),
      Gosu::Color.rgba(255, 200, 0, 200),
      Gosu::Color.rgba(150, 150, 0, 200)
    ]

    list.sample
  end

  def a_leaf_color
    list = [
      Gosu::Color.rgba(50, 200, 0, 200)
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
    if @dead || (@y > $window.height || @color.alpha <= 0)
      @dead = true
      $window.leaves.delete(self)
    end
  end
end