import "java.lang.System"
import "java.io.File"
import "javax.swing.JFileChooser"

class PophealthImporterListener

  def initialize
  end

  def play
    puts "Write logic for playing/running the importer"
  end

  def pause
    puts "Write logic for pausing the importer here"
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
    end
  end

  def save_import_results
    puts "Write logic for saving results here"
  end

  def quit
    @jframe.setVisible(false)
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
  end

end