require 'java'

java.lang.System.setProperty("javax.xml.transform.TransformerFactory","net.sf.saxon.TransformerFactoryImpl")
java.lang.System.setProperty("javax.xml.parsers.DocumentBuilderFactory","net.sf.saxon.dom.DocumentBuilderFactoryImpl")

require 'rexml/document'
require 'uri'
require 'net/http'

require 'lib/validation/schematron_validator'
require 'lib/validation/xml_schema_validator'
require 'lib/validation/validator_registry'

require 'lib/communication/uploader'

# TODO: this code should be moved to a separate launcher ruby file
# this listener handles all of the controller logic
#require 'lib/pophealth_importer_jframe'
# pophealth_listener = PophealthImporterListener.new()
# pophealth_importer_frame = PophealthImporterJframe.new(pophealth_listener)
# pophealth_listener.set_jframe(pophealth_importer_frame)
# 
# pophealth_importer_frame.show