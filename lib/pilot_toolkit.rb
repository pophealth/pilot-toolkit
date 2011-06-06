require 'java'

java.lang.System.setProperty("javax.xml.transform.TransformerFactory","net.sf.saxon.TransformerFactoryImpl")
java.lang.System.setProperty("javax.xml.parsers.DocumentBuilderFactory","net.sf.saxon.dom.DocumentBuilderFactoryImpl")

require "bundler/setup"
require 'quality-measure-engine'

require 'rexml/document'
require 'uri'
require 'net/http'

require_relative 'validation/schematron_validator'
require_relative 'validation/xml_schema_validator'
require_relative 'validation/validator_registry'
                  
require_relative 'communication/uploader'
require_relative 'stats/patient_summary_section'
require_relative 'stats/patient_summary_report'
require_relative 'stats/scanCCR'
require_relative 'pophealth_import_file'
