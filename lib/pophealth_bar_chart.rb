import "java.awt.Color"
import "java.awt.Graphics"

class PophealthBarChart < JPanel

  def initialize
    @percentage = 1.0
    @value_set = false
  end

  def set_percentage(percentage)
    @percentage = percentage
    @value_set = true
  end

  def paint(g)
    if @percentage == 0.0
      g.setColor(Color::PINK)
      g.fillRect(5, 5, 400, 20)
      g.setColor(Color::RED)
      g.drawRect(5, 5, 400, 20)
    else
      # only fill in the rectangle if the bar chart has had a percentage set
      # otherwise, it will be just a hollow rectangle
      if @value_set
        g.setColor(Color.new(179, 179, 179)) # specialized color gray
        g.fillRect(5, 5, (@percentage*400), 20)
      end
      g.setColor(Color::BLACK)
      g.drawRect(5, 5, (@percentage*400), 20)
    end
  end

end