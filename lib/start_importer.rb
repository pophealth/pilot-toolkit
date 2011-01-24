require 'java'

require 'lib/pophealth_splash_screen'
require 'lib/pophealth_importer_jframe'

pophealth_splash_screen = PophealthSplashScreen.new()
pophealth_splash_screen.setVisible(true)
begin
  sleep 3
rescue InterruptedException => ie
  $stderr.print "Problem displaying the popHealth splash screen. See: #{ie}n"
end
pophealth_splash_screen.setVisible(false)

pophealth_listener = PophealthImporterListener.new()
pophealth_importer_frame = PophealthImporterJframe.new(pophealth_listener)
pophealth_listener.set_jframe(pophealth_importer_frame)

pophealth_importer_frame.show