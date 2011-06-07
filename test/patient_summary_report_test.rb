require 'test/unit'
require 'lib/pilot_toolkit'

class PatientSummaryReportTest < Test::Unit::TestCase

  def test_from_c32
    doc = Nokogiri::XML(File.read('fixtures/TobaccoUser0028.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    psr = Stats::PatientSummaryReport.from_c32(doc)
    STDERR.puts psr.encounters.entries.size
    STDERR.puts psr.encounters.num_coded_entries
    STDERR.puts psr.encounters.mu_code_systems_found
    assert_equal 1, psr.encounters.entries.size
    assert_equal 1, psr.encounters.num_coded_entries
    assert psr.encounters.mu_code_systems_found.include?('CPT')
  end

end