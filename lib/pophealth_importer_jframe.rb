import "java.awt.BorderLayout"
import "java.awt.FlowLayout"
import "java.awt.Dimension"
import "java.util.Vector"
import "javax.swing.ImageIcon"
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
require 'lib/pophealth_list_selection_listener'
require 'lib/pophealth_summary_panel'

class PophealthImporterJframe < JFrame

  @@initial_window_dimension = Dimension.new(950, 750)

  def initialize (pophealth_listener)

    super("popHealth Continuity of Care XML Importer")

    @c32_schematron_validator = Validation::ValidatorRegistry.c32_schematron_validator
    @c32_schema_validator =     Validation::ValidatorRegistry.c32_schema_validator
    @ccr_schema_validator =     Validation::ValidatorRegistry.ccr_schema_validator

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
    @summary_text_area = PophealthSummaryPanel.new()
    @file_content_text_area = JTextArea.new()
    @file_error_text_area = JTextArea.new()
    @file_list.setCellRenderer(PophealthImporterListRenderer.new())

    @list_selection_listener = PophealthListSelectionListener.new(self)
    @file_list.add_list_selection_listener(@list_selection_listener)

    @file_scroll_pane =     JScrollPane.new(@file_list)
    @summary_scroll_pane =  JScrollPane.new(@summary_text_area)
    @display_scroll_pane =  JScrollPane.new(@file_content_text_area)
    @error_scroll_pane =    JScrollPane.new(@file_error_text_area)

    @tabbed_pane = JTabbedPane.new()
    @tabbed_pane.add("Summary Report",  @summary_scroll_pane)
    @tabbed_pane.add("File Contents",   @display_scroll_pane)
    @tabbed_pane.add("Errors/Warnings", @error_scroll_pane)

    @split_pane = JSplitPane.new(JSplitPane::HORIZONTAL_SPLIT,
                                 @file_scroll_pane,
                                 @tabbed_pane)
    @split_pane.setDividerLocation(200)

    @progress_bar = JProgressBar.new(0, 100)
    @progress_bar.set_value 0
    @progress_bar.set_string_painted false
    @progress_bar.set_border_painted true
    @progress_bar.set_preferred_size(Dimension.new(700, 20))
    bottom_panel = JPanel.new()
    bottom_panel.setLayout(FlowLayout.new())
    bottom_panel.add(JLabel.new("  Pre-Process Report Analysis:"))
    bottom_panel.add(@progress_bar)

    @content_pane.add(@split_pane,  BorderLayout::CENTER)
    @content_pane.add(bottom_panel, BorderLayout::NORTH)

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

  def update_text_areas
    if @file_list.get_selected_value.is_valid_format
      validation_errors = ""
      if (PophealthImporterListener.continuity_of_care_mode == :c32_mode)
        c32 = File.read(@file_list.get_selected_value.get_file.get_path)
        c32_schema_errors= @c32_schema_validator.validate(c32)
        validation_errors += c32_schema_errors.join("\n")
        c32_schematron_errors = @c32_schematron_validator.validate(c32)
        validation_errors += c32_schematron_errors.join("\n")
      else
        if @ccr_schema_validator
          ccr = File.read(@file_list.get_selected_value.get_file.get_path)
          ccr_schema_errors= @ccr_schema_validator.validate(ccr)
          validation_errors += ccr_schema_errors.join("\n")
        end
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

  def update_analysis_results (analysis_results)
    @summary_text_area.update_analysis_results(analysis_results)
  end

  def set_analysis_progress_bar(progress)
    @progress_bar.set_value((progress*100.0).truncate)
  end

end