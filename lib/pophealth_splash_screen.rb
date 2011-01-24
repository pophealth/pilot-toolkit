import "java.awt.BorderLayout"
import "java.awt.Dimension"
import "java.awt.Toolkit"
import "javax.swing.ImageIcon"
import "javax.swing.JLabel"
import "javax.swing.JWindow"

class PophealthSplashScreen < JWindow

  def initialize
    super()
    l = JLabel.new(ImageIcon.new("images/splash_screen.png"))
    getContentPane().add(l, BorderLayout::CENTER)
    pack()
    screenSize = Toolkit.getDefaultToolkit().getScreenSize()
    labelSize = l.getPreferredSize();
    setLocation((screenSize.width  / 2) - (labelSize.width  / 2),
                (screenSize.height / 2) - (labelSize.height / 2))
    screenSize = nil
    labelSize = nil
  end

end