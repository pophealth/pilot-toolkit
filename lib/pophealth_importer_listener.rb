import "java.lang.System"
import "javax.swing.JMenuItem"
import "javax.swing.JFileChooser"

require 'lib/pophealth_importer_thread'

class PophealthImporterListener

  def initialize
    @importer_thread = PophealthImporterThread.new()
    @importer_thread.start
  end

  def play
    @importer_thread.set_import_records_flag
  end

  def pause
    puts "Write logic for pausing"
  end

  def stop
    puts "Write logic for stopping"
  end

  def new_import
    puts "Write logic for starting a new import here"
  end

  def open
    file_chooser = JFileChooser.new()
    file_chooser.setFileSelectionMode(JFileChooser::DIRECTORIES_ONLY)
    return_value = file_chooser.showOpenDialog(@jframe);
    if (return_value == JFileChooser::APPROVE_OPTION)
      @import_directory = file_chooser.getSelectedFile()
      @importer_thread.set_import_directory(@import_directory)
      @jframe.enable_play
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
    puts "Write logic for switching to C32 mode here"
  end

  def switch_to_ccr_mode
    puts "Write logic for switching to CCR mode here"
  end

  def help
    puts "Write logic for... oh hell, who are we kidding... we're not going to ever do this"
  end

  def about
    puts "Open web browser to popHealth website"
  end

  def set_jframe (jframe)
    @jframe = jframe
    @importer_thread.set_jframe(jframe)
  end

end