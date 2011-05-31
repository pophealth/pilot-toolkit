import "java.awt.Color"
import "java.awt.Graphics"

class PophealthBarChart < JPanel

  def set_percentage(percentage)
    @percentage = percentage
  end

  def paint(g)
    if @percentage == 0.0
      g.setColor(Color::PINK)
      g.fillRect(5, 5, 400, 20)
      g.setColor(Color::RED)
      g.drawRect(5, 5, 400, 20)
    else
      g.setColor(Color.new(179, 179, 179))
      g.fillRect(5, 5, (@percentage*400), 20)
      g.setColor(Color::BLACK)
      g.drawRect(5, 5, (@percentage*400), 20)
    end
  end

end