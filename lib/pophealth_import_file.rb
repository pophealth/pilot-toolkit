import "java.io.BufferedReader"
import "java.io.FileInputStream"
import "java.io.InputStreamReader"
import "java.util.StringTokenizer"

class PophealthImportFile

  def initialize(import_file)
    @import_file = import_file
  end

  def is_valid_format
    file_extension = ""
    st = StringTokenizer.new(@import_file.getName(), ".")
    while st.hasMoreTokens
      file_extension = st.nextToken().downcase
    end
    if file_extension == "xml"
      return true
    end
    return false
  end

  def to_s
    @import_file.getName()
  end

  def file_content
    if is_valid_format
      begin
        file_content = ""
        fin =  FileInputStream.new(@import_file)
        myInput = BufferedReader.new(InputStreamReader.new(fin))
        next_line = myInput.readLine()
        while next_line
          file_content += next_line + "\n"
          next_line = myInput.readLine()
        end
      rescue Exception => e
        $stderr.print "Problem loading file contents into memory: #{e}n"
      end
      return file_content
    else
      return "Invalid file format"
    end
  end
  
  def get_file
    return @import_file
  end

end