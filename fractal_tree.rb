require "gosu"
require "matrix"

require_relative "lib/vector_ext"
require_relative "lib/branch"
require_relative "lib/leaf"

class Display < Gosu::Window
  attr_reader :tree, :leaves, :max_leaves, :growth_speed, :max_branches, :branch_thickness, :magic_divider
  def initialize
    super(Gosu.screen_width, Gosu.screen_height, fullscreen: true)
    $window = self
    @font = Gosu::Font.new(20, name: "Consolas")

    @tree = []
    @leaves=[]
    @inital_length = 250
    @branch_thickness = 6
    @magic_divider = 0.67 # how much to shorten each consecutive branch by (length * devider)
    @growth_speed = 0.1
    @max_branches = 2048# 16_386
    $angle = 25
    $angle_drift = 0

    @last_drop = Gosu.milliseconds
    @leaf_fall = 40
    @max_leaves = 127
    @solo = 1024

    plant_tree
  end

  def draw
    @font.draw_text(
"Branches #{@tree.size}/#{@max_branches}, Active Leaves: #{@leaves.size}.
Branch growth speed: #{@growth_speed.round(4)}, Branch spawn angle: #{$angle}, Branch angle drift: #{$angle_drift}
Window Width: #{self.width}, Height: #{self.height}
", 10, 10, 10) if $debug

    # if $window.tree.size+2 > $window.max_branches
    #   @branches_texture ||= Gosu.record(self.width, self.height) do
    #     @tree.each(&:draw)
    #   end
    #   @branches_texture.draw(0,0,0)
    # else
      @tree.each(&:draw)
    # end

    @leaves.each(&:draw)
  end

  def update
    self.caption = "Branches: #{@tree.size}"

    branch_out

    if Gosu.milliseconds - @last_drop > @leaf_fall
      @tree.each do |branch|
        next if branch.branched || !branch.grown

        @leaves << Leaf.new(branch.end.x, branch.end.y) if ((rand(-@solo..@solo) == @solo)) && @leaves.size <= @max_leaves
      end

      @last_drop = Gosu.milliseconds
    end

    @tree.reverse.each(&:update)
    @leaves.each(&:update)
  end

  def line(x,y, x2, y2, color, thickness = 6)
    offset = thickness / 2.0
    angle = Gosu.angle(x, y, x2, y2)
    distance = Gosu.distance(x,y, x2, y2)

    Gosu.rotate(angle, x, y) do
      Gosu.draw_rect(x-offset, y, offset, -distance, color)
    end
  end

  def button_up(id)
    case id
    when Gosu::KbTab
      $debug = !$debug
    when Gosu::KbEscape
      close
    when Gosu::KbLeft
      $angle -= 1
      regrow_tree

    when Gosu::KB_EQUALS, Gosu::KB_NUMPAD_PLUS
      @growth_speed+=0.025
    when Gosu::KB_MINUS, Gosu::KB_NUMPAD_MINUS
      @growth_speed-=0.025
      @growth_speed = 0.1 if @growth_speed < 0.1

    when Gosu::KbRight
      $angle += 1
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
    @tree.each(&:branch)
  end
end

Display.new.show