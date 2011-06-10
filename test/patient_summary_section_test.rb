require 'test/unit'
require 'lib/pilot_toolkit'

class PatientSummarySectionTest < Test::Unit::TestCase
  def test_add_entry
    section = Stats::PatientSummarySection.new("test", ["ICD9","ICD10","SNOMEDCT"])
    entry = QME::Importer::Entry.new
    entry.add_code("32000", "ICD9")
    entry.add_code("32001","ICD9")
    entry.add_code("32000", "ICD10")
    entry.add_code("32001","ICD10")
    entry.add_code(1,"GORK")
    section.add_entry(entry)

    assert_equal 1, section.alien_code_systems_found.size
    assert section.alien_code_systems_found.include?('GORK')
    assert_equal 2, section.mu_code_systems_found.size
    assert section.mu_code_systems_found.include?('ICD9')
    assert_equal 1, section.num_coded_entries

   entry.description = "test_entry 1"
   entry.add_code("32000", "ICD9")
   entry.add_code("32001","ICD9")
   entry.add_code("32000", "LOINC")
   entry.add_code("32001","ICD10")
   entry.add_code(1,"GORK")
   section.add_entry(entry)
   entry1 = QME::Importer::Entry.new
   entry1.description = "test_entry 2"
   entry1.add_code("32000", "ICD9")
   entry1.add_code("32002","ICD9")
   entry1.add_code("32000", "FOO1")
   entry1.add_code("32001","BAR1")
   section.add_entry(entry)
   entry2 = QME::Importer::Entry.new
   entry2.description = "test_entry 3"
   entry2.add_code("32000", "FOO")
   entry2.add_code("32002","FOO")
   entry2.add_code("32000", "BAR")
   entry2.add_code("32001","BAR1")
   section.add_entry(entry2)
   entry3 = QME::Importer::Entry.new
   entry3.description = "test_entry 4"
   entry3.add_code("32002", "FOO")
   entry3.add_code("32004","FOO")
   entry3.add_code("32006", "BAR")
   entry3.add_code("32008","BAR1")
   section.add_entry(entry3)
   unique_non_mu_entries = section.unique_non_mu_entries
   assert_equal Hash, unique_non_mu_entries.class
   assert_equal 1, unique_non_mu_entries.size
   assert_equal 3, unique_non_mu_entries["test"]["entries"]["test_entry 3"]["codes"].keys.size
   assert_equal 2, unique_non_mu_entries["test"]["entries"]["test_entry 3"]["codes"]["FOO"].size

   entrya = Stats::StatsEntry.fromEntry(entry)
   entry1a = Stats::StatsEntry.fromEntry(entry1)
   entry1a.description = entrya.description
   entrya.add(entry1a)
   assert_equal   2, entrya.count
   assert_equal 6, entrya.codes.size
   assert_equal 3, entrya.codes["ICD9"].size
  end
end
