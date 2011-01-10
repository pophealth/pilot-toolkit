import "java.awt.BorderLayout"
import "java.awt.Dimension"
import "java.util.Vector"
import "javax.swing.JFrame"
import "javax.swing.JList"
import "javax.swing.JPanel"
import "javax.swing.JScrollPane"
import "javax.swing.JSplitPane"
import "javax.swing.JTextArea"

require 'lib/pophealth_importer_menu_bar'
require 'lib/pophealth_importer_listener'
require 'lib/pophealth_importer_control_panel'

class PophealthImporterJframe < JFrame

  @@initial_window_dimension = Dimension.new(700, 500)

  def initialize (pophealth_listener)

    super("popHealth Continuity of Care XML Importer")

    # setup children UI components
    @pophealth_importer_menu_bar = PophealthImporterMenuBar.new()
    @pophealth_importer_menu_bar.add_pophealth_importer_listener(pophealth_listener)

    # pull it all together...
    setJMenuBar(@pophealth_importer_menu_bar)
    @content_pane = JPanel.new()
    @content_pane.setLayout(BorderLayout.new())
    @file_list = JList.new()

    @control_panel = PophealthImporterControlPanel.new()
    @content_pane.add(@control_panel, BorderLayout::NORTH)

    patients = Vector.new()
    patients.add("Fred Smith")
    patients.add("Zelda Smith")
    patients.add("Stephanie Smith")
    patients.add("Mindy Smith")
    @file_list = JList.new(patients)
    @text_area = JTextArea.new()
    @file_scroll_pane = JScrollPane.new(@file_list)
    @split_pane = JSplitPane.new(JSplitPane::HORIZONTAL_SPLIT,
                                 @file_scroll_pane,
                                 @text_area)
    @split_pane.setDividerLocation(200)
    @content_pane.add(@split_pane, BorderLayout::CENTER)

    getContentPane().add(@content_pane)
    setSize(@@initial_window_dimension)
  end

  def get_control_panel
    @control_panel
  end

end