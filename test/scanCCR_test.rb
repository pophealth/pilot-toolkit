require 'test/unit'
require 'lib/pilot_toolkit'

class CCRParseAndStatsTest < Test::Unit::TestCase

  def test_parseandsummarize
         doc = Nokogiri::XML(File.read('fixtures/10781.xml'))
         psr = Stats::PatientSummaryReport.from_ccr(doc)
         summary = psr.summary
         assert_equal 1, psr.summary[:conditions]["entries"]
         assert_equal 1, psr.summary[:conditions]["mu coded entries"]
         assert_equal 1, psr.summary[:conditions]["entries"]
         unique_non_mu_entries = psr.unique_non_mu_entries
         assert_equal 3, unique_non_mu_entries.keys.size  
         assert_equal 4, summary.keys.size  
  end
end
