require 'test/unit'
require 'lib/pilot_toolkit'

class PatientSummaryReportTest < Test::Unit::TestCase

  def test_from_c32
    # Read and validate a C32 file
    validator = Validation::ValidatorRegistry.c32_schematron_validator
    c32 = File.read('fixtures/VitalsResults.xml')
    results = validator.validate(c32)
    assert results
    doc = Nokogiri::XML(c32)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    # Generate a patient summary report
    psr = Stats::PatientSummaryReport.from_c32(doc)
    STDERR.puts psr.results.entries.size
    STDERR.puts psr.results.num_coded_entries
    STDERR.puts psr.results.mu_code_systems_found
    assert_equal 1, psr.results.entries.size
    assert_equal 0, psr.results.num_coded_entries
    assert_equal 2, psr.vital_signs.entries.size, "vital signs entries"
    assert_equal 2, psr.vital_signs.num_coded_entries, "vital signs coded entries"
    assert_equal 0, psr.vital_signs.num_mu_coded_entries, "vital signs coded entries"
    map = JSON.parse(File.open('fixtures/mapping.json',"r").read)
    # Patch the file
    patcher = C32Preprocessor::PatchCodesDocument.new(doc,map)
    patcher.process
    c32 = doc.to_xml(:indent => 5, :encoding => 'UTF-8')
    # Validate the patched XML
    results = validator.validate(c32)
    assert results
    doc = Nokogiri::XML(c32)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    # Run a patient summary report, and verify that things actually changed.
    psr2 = Stats::PatientSummaryReport.from_c32(doc)
    STDERR.puts psr2.results.entries.size
    STDERR.puts psr2.results.num_coded_entries
    STDERR.puts psr2.results.mu_code_systems_found
    assert_equal 1, psr2.results.entries.size
    assert_equal 1, psr2.results.num_coded_entries, "MU coding systems #{psr2.summary}"
    assert_equal 2, psr2.vital_signs.entries.size, "vital signs entries"
    assert_equal 2, psr2.vital_signs.num_coded_entries, "vital signs coded entries"
    assert_equal 2, psr2.vital_signs.num_mu_coded_entries, "vital signs coded entries"
  end

end