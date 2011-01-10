import "java.awt.event.ActionEvent"
import "java.awt.event.ActionListener"
import "java.util.Vector"
import "javax.swing.JCheckBoxMenuItem"
import "javax.swing.JMenu"
import "javax.swing.JMenuBar"
import "javax.swing.JMenuItem"

class PophealthImporterMenuBar < JMenuBar

  include java.awt.event.ActionListener

  def initialize

    super()

    # all the listeners registered with this menu bar
    @pophealth_listeners = Vector.new()

    # Setup the menus...
    @file_menu = JMenu.new("File")
    @edit_menu = JMenu.new("Edit")
    @mode_menu = JMenu.new("Import Mode")
    @view_menu = JMenu.new("View")
    @help_menu = JMenu.new("Help")

    # ...and then menu items, while configuring them to
    # callback to this menubar when a user clicks on them
    @new_menu_item =   JMenuItem.new("New")
    @new_menu_item.addActionListener(self)
    @open_menu_item =  JMenuItem.new("Open")
    @open_menu_item.addActionListener(self)
    @save_menu_item =  JMenuItem.new("Save")
    # will only be able to save after doing an import
    @save_menu_item.setEnabled(false)
    @save_menu_item.addActionListener(self)
    @quit_menu_item =  JMenuItem.new("Quit")
    @quit_menu_item.addActionListener(self)

    @run_menu_item =   JMenuItem.new("Play")
    @run_menu_item.addActionListener(self)
    @stop_menu_item =  JMenuItem.new("Stop")
    @stop_menu_item.setEnabled(false)
    @stop_menu_item.addActionListener(self)
    @pause_menu_item = JMenuItem.new("Pause")
    @pause_menu_item.setEnabled(false)
    @pause_menu_item.addActionListener(self)

    @c32_mode_menu_item = JCheckBoxMenuItem.new("C32", true)
    @c32_mode_menu_item.addActionListener(self)
    @ccr_mode_menu_item = JCheckBoxMenuItem.new("CCR", false)
    # TODO: Comment out next line when CCR importer is integrated
    @ccr_mode_menu_item.setEnabled(false)
    @ccr_mode_menu_item.addActionListener(self)

    @help_menu_item =  JMenuItem.new("Help")
    @help_menu_item.setEnabled(false)
    @help_menu_item.addActionListener(self)
    @about_menu_item = JMenuItem.new("About")
    @about_menu_item.addActionListener(self)

    # Configure the menus with menu items
    @file_menu.add(@new_menu_item)
    @file_menu.add(@open_menu_item)
    @file_menu.add(@save_menu_item)
    @file_menu.addSeparator()
    @file_menu.add(@quit_menu_item)

    @mode_menu.add(@c32_mode_menu_item)
    @mode_menu.add(@ccr_mode_menu_item)

    @edit_menu.add(@run_menu_item)
    @edit_menu.add(@pause_menu_item)
    @edit_menu.add(@stop_menu_item)
    @edit_menu.add(@mode_menu)

    @help_menu.add(@help_menu_item)
    @help_menu.addSeparator()
    @help_menu.add(@about_menu_item)

    ## ... and hook them onto the menubar
    add(@file_menu)
    add(@edit_menu)
    add(@help_menu)
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
          when "New"   : registered_listener.new_import
          when "Open"  : registered_listener.open
          when "Save"  : registered_listener.save_import_results
          when "Quit"  : registered_listener.quit
          when "Play"  : registered_listener.play
          when "Pause" : registered_listener.pause
          when "Stop"  : registered_listener.stop
          when "C32"   : registered_listener.switch_to_c32_mode
          when "CCR"   : registered_listener.switch_to_ccr_mode
          when "Help"  : registered_listener.help
          when "About" : registered_listener.about
        end
      end
    end
  end

end