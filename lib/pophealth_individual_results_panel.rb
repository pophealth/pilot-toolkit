import "java.awt.BorderLayout"
import "java.awt.FlowLayout"
import "java.awt.Font"
import "java.awt.Color"
import "java.awt.Dimension"
import "javax.swing.JPanel"
import "javax.swing.JLabel"

require 'lib/pophealth_bar_chart'

class PophealthIndividualResultsPanel < JPanel

  def initialize(display_name, display_numeric_visualization)
    super()
    self.setLayout(BorderLayout.new(10, 10))
    self.setPreferredSize(Dimension.new(500, 35))
    left_panel = JPanel.new()
    left_panel.setPreferredSize(Dimension.new(220, 35))
    left_panel.setLayout(BorderLayout.new(10, 10))
    display_label = JLabel.new(display_name)
    # make the font bold
    display_label.setFont(Font.new(display_label.getFont().getName(),
                          Font::BOLD,
                          display_label.getFont().getSize()))
    if !display_numeric_visualization
      display_label.setForeground(Color.new(129, 179, 60)) # popHealth green
    else
      display_label.setForeground(Color.new(86, 160, 171)) # popHealth blue
    end
    left_panel.add(display_label, BorderLayout::CENTER)
    self.add(left_panel, BorderLayout::WEST)
    if display_numeric_visualization
      center_panel = JPanel.new()
      center_panel.setLayout(BorderLayout.new(10, 10))
      @bar_chart = PophealthBarChart.new()
      self.add(@bar_chart, BorderLayout::CENTER)
      percentage_panel = JPanel.new()
      percentage_panel.setLayout(BorderLayout.new(10, 10))
      @percentage_label = JLabel.new("")
      percentage_panel.add(@percentage_label, BorderLayout::CENTER)
      self.add(percentage_panel, BorderLayout::EAST)
    end
  end

  def set_percentage(percentage)
    @bar_chart.set_percentage(percentage)
    percentage = percentage * 100
    @percentage_label.setText(percentage.truncate.to_s + "% ")
    if percentage == 0.0
      @percentage_label.setForeground(Color::RED)
      @percentage_label.setFont(Font.new(@percentage_label.getFont().getName(),
                                Font::BOLD,
                                @percentage_label.getFont().getSize()))
    else
      @percentage_label.setForeground(Color::BLACK)
      @percentage_label.setFont(Font.new(@percentage_label.getFont().getName(),
                                Font::PLAIN,
                                @percentage_label.getFont().getSize()))
    end
  end

end