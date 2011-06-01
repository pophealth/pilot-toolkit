import "java.awt.FlowLayout"
import "java.util.Vector"
import "javax.swing.JButton"
import "javax.swing.JPanel"

require 'lib/pophealth_importer_listener'

class PophealthImporterControlPanel < JPanel

  include java.awt.event.ActionListener

  def initialize

    super()

    # all the listeners registered with this menu bar
    @pophealth_listeners = Vector.new()

    @play_button =  JButton.new("Play")
    @play_button.setEnabled(false)
    @play_button.addActionListener(self)
    @stop_button =  JButton.new("Stop")
    @stop_button.setEnabled(false)
    @stop_button.addActionListener(self)

    self.setLayout(FlowLayout.new())
    self.add(@play_button)
    self.add(@stop_button)
  end

  # Add a listener to this menu bar to recieve popHealth
  # importer notifications
  def add_pophealth_importer_listener (pophealth_listener)
    # always remember thread safety when processing events!
    @pophealth_listeners.synchronized do
      if !@pophealth_listeners.contains(pophealth_listener)
        @pophealth_listeners.add(pophealth_listener)
      end
    end
  end

  # Tries to find and remove module to this menu bar for receiving
  # popHealth importer notifications
  def remove_pophealth_importer_listener (pophealth_listener)
    # always remember thread safety when processing events!
    @pophealth_listeners.synchronized do
      @pophealth_listeners.each do |registered_listener|
        if registered_listener == pophealth_listener
          @pophealth_listeners.remove(registered_listener)
          return
        end
      end
    end
  end

  # All the menus callback this method on the parent menu bar when a user
  # clicks on a menu item
  def actionPerformed(e)
    # always remember thread safety when processing events!
    @pophealth_listeners.synchronized do
      @pophealth_listeners.each do |registered_listener|
        case e.getActionCommand()
          when "Play"   : registered_listener.play
          when "Stop"   : registered_listener.stop
        end
      end
    end
  end

  def set_play_mode(play_mode)
    if play_mode
      @play_button.setEnabled(false)
      @stop_button.setEnabled(true)
    else
      @play_button.setEnabled(true)
      @stop_button.setEnabled(false)
    end
  end

  def enable_play
    @play_button.setEnabled(true)
  end

end