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