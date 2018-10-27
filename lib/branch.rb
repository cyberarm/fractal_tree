class Branch
  attr_accessor :start, :end, :color, :branched, :parent, :grown
  def initialize(x1,y1, x2,y2, tree, length, parent = nil)
    @start = Vector[x1,y1]
    @end   = Vector[x1,y1]
    @target= Vector[x2,y2]
    @tree = tree
    @length = (length * rand(0.75..1.0))
    @parent   = parent

    @thickness = $window.branch_thickness
    @shortener = $window.magic_divider
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
    if $window.tree.size+2 > $window.max_branches
      @grown = true
      return
    end
    return unless @grown
    return if @branched
    return if @length < 10

    @branched = true

    direction = (Gosu.angle(@start.x, @start.y, @end.x, @end.y) + ($angle - rand($angle_drift))).gosu_to_radians
    x = @end.x+(@length * Math.cos(direction))
    y = @end.y+(@length * Math.sin(direction))

    @tree << Branch.new(@end.x, @end.y, x, y, @tree, (@length * rand(@shortener..@shortener+0.03)), self)

    direction = (Gosu.angle(@start.x, @start.y, @end.x, @end.y) - ($angle + rand($angle_drift))).gosu_to_radians
    x = @end.x+(@length * Math.cos(direction))
    y = @end.y+(@length * Math.sin(direction))

    @tree << Branch.new(@end.x, @end.y, x, y, @tree, (@length * rand(@shortener..@shortener+0.08)), self)
  end

  def draw
    $window.line(@start.x, @start.y, @end.x, @end.y, @color, @thickness)
  end

  def update
    grow unless @grown

    @leaf = nil if @leaf&.dead

    if @leaf
      if @leaf.branch_is_sapling
        if @branched
          @leaf.dead = true
          @leaf = nil
        elsif @grown && !@branched
          @leaf.dead = true
          @leaf = nil
        end
      end

    else
      if !@branched && !@grown
        grow_leaf(true)
      elsif @grown && @length <= ($window.inital_length * 0.1) # Top branch
        grow_leaf
      end
    end

    animate if $debug && Gosu.button_down?(Gosu::KbBacktick)
  end

  def grow
    @current_length+= $window.growth_speed
    direction = (Gosu.angle(@start.x, @start.y, @target.x, @target.y)).gosu_to_radians
    x = @end.x+(@current_length * Math.cos(direction))
    y = @end.y+(@current_length * Math.sin(direction))

    @leaf.x, @leaf.y = x, y if @leaf

    @end = Vector[x, y]

    length = Gosu.distance(@start.x, @start.y, @end.x, @end.y)
    if length >= @length
      @current_length = @length
      @grown = true
    end
  end

  def grow_leaf(sapling = false)
    return if $window.leaves.size >= $window.max_leaves
    @leaf = Leaf.new(@end.x, @end.y, sapling)
    $window.leaves << @leaf
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