class Branch
  attr_accessor :start, :end, :color, :branched, :parent
  def initialize(x1,y1, x2,y2, tree, length, parent = nil)
    @start = Vector[x1,y1]
    @end   = Vector[x2,y2]
    @tree = tree
    @length = length
    @parent   = parent

    @thickness = 6#@length# * 0.4
    @shortener = 0.67
    @branched = false
    @color = Gosu::Color.rgb(150, 100, 50)

    @born = Gosu.milliseconds
    @wind_scaler = 1000.0
    @bounce_scaler = 5_00.0
    @wind_amplifier = 1.0 # x axis
    @bounce_amplifier = 1.0 # y axis
  end

  def branch
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
    x = @end.x + ((Math.sin((Gosu.milliseconds-@born) / @wind_amplifier)) * @wind_amplifier)
    y = @end.y + ((Math.sin(Gosu.milliseconds-@born / @bounce_scaler)) * @bounce_amplifier)

    v = Vector[x, y]
    @end = v

    if @parent
      @start = @parent.end
    end
  end
end