import "java.awt.BorderLayout"
import "java.awt.Dimension"
import "java.lang.System"
import "javax.swing.BorderFactory"
import "javax.swing.JDialog"
import "javax.swing.JMenuItem"
import "javax.swing.JFileChooser"
import "javax.swing.JProgressBar"
import "javax.swing.border.Border"

require 'lib/pophealth_analysis_thread'
require 'lib/pophealth_importer_thread'
require 'lib/stats/patient_summary_section'
require 'lib/stats/patient_summary_report'
require 'nokogiri'

class PophealthImporterListener

  @@continuity_of_care_mode = :c32_mode

  def self.continuity_of_care_mode
    @@continuity_of_care_mode
  end

  def initialize
    @importer_thread = PophealthImporterThread.new()
    @importer_thread.start
  end

  def play
    @importer_thread.set_import_records_flag
  end

  def stop
    puts "Write logic for stopping"
  end

  def open
    file_chooser = JFileChooser.new()
    file_chooser.setFileSelectionMode(JFileChooser::DIRECTORIES_ONLY)
    return_value = file_chooser.showOpenDialog(@jframe)
    if (return_value == JFileChooser::APPROVE_OPTION)
      @import_directory = file_chooser.getSelectedFile()
      @importer_thread.set_import_directory(@import_directory)
      analysis_thread = PophealthAnalysisThread.new()
      analysis_thread.set_parent_jframe(@jframe)
      analysis_thread.set_import_directory(@import_directory)
      analysis_thread.start
    end
  end

  def save_import_results
    puts "Write logic for saving results here"
  end

  def quit
    @jframe.setVisible(false)
    @importer_thread.shutdown_importer_thread
    System.exit(0)
  end

  def switch_to_c32_mode
    @@continuity_of_care_mode = :c32_mode
  end

  def switch_to_ccr_mode
    @@continuity_of_care_mode = :ccr_mode
  end

  def about
    system("open", "http://projectpophealth.org/")
  end

  def set_jframe (jframe)
    @jframe = jframe
    @importer_thread.set_jframe(jframe)
  end

end