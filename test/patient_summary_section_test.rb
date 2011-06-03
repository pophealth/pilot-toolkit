require 'test/unit'
require 'lib/pilot_toolkit'

class PatientSummarySectionTest < Test::Unit::TestCase
  def test_add_entry
    section = Stats::PatientSummarySection.new("test", ["ICD9","ICD10","SNOMEDCT"])
    entry = QME::Importer::Entry.new
    entry.add_code(32000, "ICD9")
    entry.add_code(32001,"ICD9")
    entry.add_code(32000, "ICD10")
    entry.add_code(32001,"ICD10")
    entry.add_code(1,"GORK")
    section.add_entry(entry)
    assert_equal 1, section.alien_code_systems_found.size
    assert section.alien_code_systems_found.include?('GORK')
    assert_equal 2, section.mu_code_systems_found.size
    assert section.mu_code_systems_found.include?('ICD9')
    assert_equal 1, section.num_coded_entries
  end
end
