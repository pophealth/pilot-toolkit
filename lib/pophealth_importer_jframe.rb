import "java.awt.BorderLayout"
import "java.awt.Dimension"
import "java.util.Vector"
import "javax.swing.JFrame"
import "javax.swing.JList"
import "javax.swing.JPanel"
import "javax.swing.JScrollPane"
import "javax.swing.JSplitPane"
import "javax.swing.JTabbedPane"
import "javax.swing.JTextArea"

require 'lib/pilot_toolkit'
require 'lib/pophealth_import_file'
require 'lib/pophealth_importer_control_panel'
require 'lib/pophealth_importer_list_renderer'
require 'lib/pophealth_importer_menu_bar'
require 'lib/pophealth_importer_listener'
require 'lib/pophealth_importer_listener'
require 'lib/pophealth_list_selection_listener'

class PophealthImporterJframe < JFrame

  @@initial_window_dimension = Dimension.new(700, 500)

  def initialize (pophealth_listener)

    super("popHealth Continuity of Care XML Importer")

    @schematron_validator = Validation::ValidatorRegistry.c32_schematron_validator
    @schema_validator = Validation::ValidatorRegistry.c32_xml_schema_validator

    # setup children UI components
    @pophealth_importer_menu_bar = PophealthImporterMenuBar.new()
    @pophealth_importer_menu_bar.add_pophealth_importer_listener(pophealth_listener)

    # pull it all together...
    setJMenuBar(@pophealth_importer_menu_bar)
    @content_pane = JPanel.new()
    @content_pane.setLayout(BorderLayout.new())

    @control_panel = PophealthImporterControlPanel.new()
    @control_panel.add_pophealth_importer_listener(pophealth_listener)
    @content_pane.add(@control_panel, BorderLayout::SOUTH)

    @file_list = JList.new(Vector.new())
    @file_content_text_area = JTextArea.new()
    @file_error_text_area = JTextArea.new()
    @file_list.setCellRenderer(PophealthImporterListRenderer.new())

    @list_selection_listener = PophealthListSelectionListener.new(self)
    @file_list.add_list_selection_listener(@list_selection_listener)
    #@file_list.add_list_selection_listener do |list_selection_event|
    #  if @file_list.get_value_is_adjusting
    #    @file_content_text_area.set_text(@file_list.get_selected_value.file_content.to_s)
    #  end
    #end
    @file_scroll_pane = JScrollPane.new(@file_list)
    @display_scroll_pane = JScrollPane.new(@file_content_text_area)
    @error_scroll_pane = JScrollPane.new(@file_error_text_area)

    @tabbed_pane = JTabbedPane.new()
    @tabbed_pane.add("File Contents", @display_scroll_pane)
    @tabbed_pane.add("Errors/Warnings", @error_scroll_pane)

    @split_pane = JSplitPane.new(JSplitPane::HORIZONTAL_SPLIT,
                                 @file_scroll_pane,
                                 @tabbed_pane)
    @split_pane.setDividerLocation(200)
    @content_pane.add(@split_pane, BorderLayout::CENTER)

    getContentPane().add(@content_pane)
    setSize(@@initial_window_dimension)
  end

  def get_control_panel
    @control_panel
  end

  def set_play_mode(play_mode)
    @pophealth_importer_menu_bar.set_play_mode(play_mode)
    @control_panel.set_play_mode(play_mode)
  end

  def enable_play
    @pophealth_importer_menu_bar.enable_play
    @control_panel.enable_play
  end

  def set_patient_directory(patient_directory)
    @patient_directory = patient_directory
    @patient_files = patient_directory.listFiles() 
    patients_files_vector = Vector.new()
    number_patient_files = @patient_files.length
    counter = 0
    while counter < number_patient_files
      patients_files_vector.add(PophealthImportFile.new(@patient_files[counter]))
      counter += 1
    end
    @file_list.setListData(patients_files_vector)
  end

  def select_item(index)
    clear_selection
    @file_list.addSelectionInterval(index, index)
  end

  def clear_selection
    @file_list.clearSelection
  end

  def toggle_pause
    @pophealth_importer_menu_bar.toggle_pause
    @control_panel.toggle_pause
  end

  def update_text_areas
    if @file_list.get_selected_value.is_valid_format
      validation_errors = ""
      c32 = File.read(@file_list.get_selected_value.get_file.get_path)
      c32_schema_errors= @schema_validator.validate(c32)
      puts "Number of schema errors is " + c32_schema_errors.length.to_s
      for i in 1..c32_schema_errors.length
         puts "Schema error is " + c32_schema_errors[(i-1)].to_s
         validation_errors += c32_schema_errors[(i-1)].to_s + "\n"
      end
      c32_schematron_errors = @schematron_validator.validate(c32)
      puts "Number of schematron errors is " + c32_schematron_errors.length.to_s
      for j in 1..c32_schema_errors.length
        puts "Schematron error is " + c32_schematron_errors[(j-1)].to_s
        validation_errors += c32_schematron_errors[(j-1)].to_s + "\n"
      end
      @file_error_text_area.set_text(validation_errors)
    else
      @file_error_text_area.set_text("")
    end
    @file_content_text_area.set_text(@file_list.get_selected_value.file_content.to_s)
  end

  def get_file_list
    return @file_list
  end

end