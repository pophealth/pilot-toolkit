class PophealthListSelectionListener

  include javax.swing.event.ListSelectionListener

  def initialize(jf)
    @jframe = jf
  end

  def valueChanged(lse)
    if @jframe.get_file_list.get_value_is_adjusting
      @jframe.update_text_areas
    end
  end

end