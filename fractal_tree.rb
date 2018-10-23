require "gosu"
require "matrix"

require_relative "lib/vector_ext"
require_relative "lib/branch"
require_relative "lib/leaf"

class Display < Gosu::Window
  attr_reader :tree, :leaves
  def initialize
    # super((Gosu.screen_width * 0.5).round, (Gosu.screen_height * 0.5).round, fullscreen: false)
    super(Gosu.screen_width, Gosu.screen_height, true)
    $window = self
    @font = Gosu::Font.new(20, name: "Consolas")

    @tree = []
    @leaves=[]
    @inital_length = 250
    $angle = 15
    $angle_drift = 0

    @last_drop = Gosu.milliseconds
    @leaf_fall = 40
    @max_leaves = 50

    plant_tree
  end

  def draw
    @font.draw_text(
"Branches #{@tree.size}, Active Leaves: #{@leaves.size}.
First Active Leaf: #{@leaves.first&.x&.round}:#{@leaves.first&.y&.round}, alpha: #{@leaves.first&.color&.alpha}
Branch spawn angle: #{$angle}, Branch angle drift: #{$angle_drift}
Window Width: #{self.width}, Height: #{self.height}
", 10, 10, 10)
    @tree.each do |branch|
      line(branch.start.x, branch.start.y, branch.end.x, branch.end.y, branch.color)
      if !branch.branched
        draw_rect(branch.end.x-7, branch.end.y-4, 8, 8, Gosu::Color::GREEN)
      end
    end

    @leaves.each(&:draw)
  end

  def update
    self.caption = "Branches: #{@tree.size}"

    branch_out

    if Gosu.milliseconds - @last_drop > @leaf_fall
      @tree.each do |branch|
        next unless branch.branched

        @leaves << Leaf.new(branch.end.x, branch.end.y) if rand(0..1000) == 50 if @leaves.size <= @max_leaves
      end

      @last_drop = Gosu.milliseconds
    end

    @leaves.each(&:update)
  end

  def line(x,y, x2, y2, color, width = 6)
    width.times do |i|
      Gosu.draw_line(
        x-i, y, color,
        x2-i, y2, color
      )
    end
  end

  def button_up(id)
    case id
    when Gosu::KbEscape
      close
    when Gosu::KbLeft
      $angle -= 5
      regrow_tree

    when Gosu::KbRight
      $angle += 5
      regrow_tree

    when Gosu::KbUp
      $angle_drift += 1
      regrow_tree
    when Gosu::KbDown
      $angle_drift -= 1
      regrow_tree
    end
  end

  def regrow_tree
    @leaves.clear
    @tree.clear

    plant_tree
    branch_out
  end

  def plant_tree
    @tree << Branch.new(self.width / 2, self.height, self.width / 2, self.height - @inital_length, @tree, @inital_length)
  end

  def branch_out
    list = []
    @tree.each {|b| list << b}

    list.each(&:branch)
  end
end

Display.new.show