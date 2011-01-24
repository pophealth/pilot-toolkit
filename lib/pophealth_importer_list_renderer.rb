import "java.awt.Color"
import "java.awt.Component"
import "javax.swing.JLabel"
import "javax.swing.JList"

class PophealthImporterListRenderer

  include javax.swing.ListCellRenderer

  def getListCellRendererComponent(list,
                                   value,
                                   index,
                                   isSelected,
                                   cellHasFocus)
    component = JLabel.new()
    component.setText(value.to_s())
    if (value.is_valid_format)
      if isSelected
        component.setForeground(Color::black)
      else
        component.setForeground(Color::gray)
      end
    else
      if isSelected
        component.setForeground(Color::red)
      else
        component.setForeground(Color::pink)
      end
    end
    return component
  end
end
