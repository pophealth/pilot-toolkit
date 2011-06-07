require 'quality-measure-engine'
require 'patient_summary_report'
require 'nokogiri'
require 'json'

outfp = File.open(ARGV[1],"w")
doc = Nokogiri::XML(File.open(ARGV[0]) )
doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
psr = Stats::PatientSummaryReport.from_c32(doc)
psr.dump
outfp.puts JSON.pretty_generate(psr.summary)
STDERR.puts JSON.pretty_generate(psr.unique_non_mu_entries)
