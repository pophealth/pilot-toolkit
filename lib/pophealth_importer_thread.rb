import "java.lang.Thread"

class PophealthImporterThread < Thread

  def initialize
    @shutdown = false
    @import_records = false
  end

  def run
    # forever loop
    begin
      self.synchronized do
        if @import_records
          @jframe.set_play_mode(true)
          files = @import_directory.listFiles()
          for i in (0..(files.length-1))
            @jframe.select_item(i)
            @jframe.update_text_areas
          end
          @jframe.set_play_mode(false)
          @import_records = false
        end
      end
      # busy polling is set to 1 second
      sleep 1
    end until @shutdown
  end

  def shutdown_importer_thread
    self.synchronized do
      @shutdown = true
    end
  end

  def set_import_records_flag
    self.synchronized do
      @import_records = true
    end
  end

  def set_jframe (jframe)
    self.synchronized do
      @jframe = jframe
    end
  end

  def set_import_directory(import_directory)
    @import_directory = import_directory
    @jframe.set_patient_directory(import_directory)
  end

  def pause
    @import_records = false
  end

end