class Branch
  attr_accessor :start, :end, :color, :branched
  def initialize(x1,y1, x2,y2, tree, length)
    @start = Vector[x1,y1]
    @end   = Vector[x2,y2]
    @tree = tree
    @length = length

    @shortener = 0.67

    @branched = false
    @color = Gosu::Color.rgb(150, 100, 50)
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

    direction = ((Gosu.angle(@start.x, @start.y, @end.x, @end.y) + $angle - rand($angle_drift)) - 90.0) * (Math::PI / 180.0)
    x = @end.x+(@length * Math.cos(direction))
    y = @end.y+(@length * Math.sin(direction))

    @tree << Branch.new(@end.x, @end.y, x, y, @tree, (@length * @shortener))

    direction = ((Gosu.angle(@start.x, @start.y, @end.x, @end.y) - $angle + rand($angle_drift)) - 90.0) * (Math::PI / 180.0)
    x = @end.x+(@length * Math.cos(direction))
    y = @end.y+(@length * Math.sin(direction))

    @tree << Branch.new(@end.x, @end.y, x, y, @tree, (@length * @shortener))
  end
end