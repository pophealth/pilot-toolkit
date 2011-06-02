require 'quality-measure-engine'
require 'patient_summary_report'
require 'nokogiri'
require 'json'


  doc = Nokogiri::XML(File.open(ARGV[0]) )
  doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
  psr = Stats::PatientSummaryReport.from_c32(doc)
  psr.dump
  STDERR.puts JSON.pretty_generate(psr.summary)

