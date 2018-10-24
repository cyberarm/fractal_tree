class Branch
  attr_accessor :start, :end, :color, :branched, :parent, :grown
  def initialize(x1,y1, x2,y2, tree, length, parent = nil)
    @start = Vector[x1,y1]
    @end   = Vector[x1,y1]
    @target= Vector[x2,y2]
    @tree = tree
    @length = length
    @parent   = parent

    @thickness = 6#@length# * 0.4
    @shortener = 0.67
    @branched = false
    @grown = false
    @current_length = 0
    @color = Gosu::Color.rgb(150, 100, 50)

    @born = Gosu.milliseconds
    @wind_scaler = 1000.0
    @bounce_scaler = 5_00.0
    @wind_amplifier = 1.0 # x axis
    @bounce_amplifier = 1.0 # y axis
  end

  def branch
    return unless @grown
    return if @branched
    return if @length < 10
    @branched = true
    _angle = 0
    begin
      _angle = Math.tan((@end.y - @start.y) / (@end.x - @start.x))
    rescue ZeroDivisionError
    end

    direction = (Gosu.angle(@start.x, @start.y, @end.x, @end.y) + ($angle - rand($angle_drift))).gosu_to_radians
    x = @end.x+(@length * Math.cos(direction))
    y = @end.y+(@length * Math.sin(direction))

    @tree << Branch.new(@end.x, @end.y, x, y, @tree, (@length * rand(@shortener..0.7)), self)

    direction = (Gosu.angle(@start.x, @start.y, @end.x, @end.y) - ($angle + rand($angle_drift))).gosu_to_radians
    x = @end.x+(@length * Math.cos(direction))
    y = @end.y+(@length * Math.sin(direction))

    @tree << Branch.new(@end.x, @end.y, x, y, @tree, (@length * rand(@shortener..0.75)), self)
  end

  def draw
    $window.line(@start.x, @start.y, @end.x, @end.y, @color, @thickness)
    if !@branched
      Gosu.draw_rect(@end.x-7, @end.y-4, 8, 8, Gosu::Color::GREEN)
    end
  end

  def update
    grow unless @grown
    animate if $debug && Gosu.button_down?(Gosu::KbBacktick)
  end

  def grow
    @current_length+= $window.growth_speed
    direction = (Gosu.angle(@start.x, @start.y, @target.x, @target.y)).gosu_to_radians
    x = @end.x+(@current_length * Math.cos(direction))
    y = @end.y+(@current_length * Math.sin(direction))

    @end = Vector[x, y]

    length = Gosu.distance(@start.x, @start.y, @end.x, @end.y)
    if length >= @length
      @current_length = @length
      @grown = true
    end
  end

  def animate
    x = @end.x + ((Math.sin((Gosu.milliseconds-@born) / @wind_amplifier)) * @wind_amplifier)
    y = @end.y + ((Math.sin(Gosu.milliseconds-@born / @bounce_scaler)) * @bounce_amplifier)

    v = Vector[x, y]
    @end = v

    if @parent
      @start = @parent.end
    end
  end
end