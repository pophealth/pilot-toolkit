require 'quality-measure-engine'
require 'patient_summary_report'
require 'nokogiri'

$coded_values = {}
$uncoded = {}

module CCRscan

  class CCR

    def initialize(ccrFilePath, summaryFilePath)
      @ccrFilePath = ccrFilePath
      @summaryFilePath = summaryFilePath
      STDERR.puts "initialize:  ccrFilePath = #{@ccrFilePath}"
      @doc = Nokogiri::XML(File.open(@ccrFilePath))
      # @doc.remove_namespaces!()
      @summaryfp = File.open(@summaryFilePath,"w")
      @summary = {}
      @patientSummaryReport = Stats::PatientSummaryReport.new
    end

    # Adds any uncoded values discovered to the (global) uncoded_values_hash
    # and returns a hash with stats on coding
    def process(uncoded_values_hash)
      @uncoded = uncoded_values_hash
      # uncoded_encounters = find_uncoded_encounters()
      # uncoded_products = find_uncoded_products()
      uncoded_problems = find_uncoded_problems()
      uncoded_vital_results = find_uncoded_results("VitalSigns")
      uncoded_test_results = find_uncoded_results("Results")
      # uncoded_alerts = find_uncoded_alerts()
      @summaryfp.puts JSON.pretty_generate(@summary)
      @summaryfp.close
    end

    # normalize_coding_system attempts to simplify analysis of the XML doc by 
    # normalizing the names of the coding systems.  Input is a single "Code" node 
    # in the tree, and the side effect is to edit the CodingSystem subnode.
    def normalize_coding_system(code)
      lookup = {
        "lnc" => "LOINC",
        "loinc" => "LOINC",
        "cpt" => "CPT",
        "cpt-4" => "CPT",
        "snomedct" => "SNOMEDCT",
        "snomed-ct" => "SNOMEDCT",
        "rxnorm" => "Rxnorm",
        "icd9-cm" => "ICD9",
        "icd9" => "ICD9"
      }
      codingsystem = lookup[code.xpath('./CodingSystem')[0].content.downcase]
      if(codingsystem)
        code.xpath('./CodingSystem')[0].content = codingsystem
      end
    end

    def find_uncoded_problems()
      problems = @doc.xpath("//Problem")
      STDERR.puts "Problems: #{problems.size}"
      problems.each do |problem|
        entry = QME::Importer::Entry.new
        codes = problem.xpath("./Description/Code")
        desctext = problem.xpath("./Description/Text")[0].content
        if codes.size > 0
          found_code = true
            codes.each do |code|
            normalize_coding_system(code)
            codetext = code.xpath("./CodingSystem")[0].content
            entry.add_code(codetext, code.xpath("./Value")[0].content)
          end
        end
        @patientSummaryReport.conditions.add_entry(entry)
      end
    end

    def find_uncoded_results(type)
      results = @doc.xpath("//" + type + "/Result")
      results.each do |result|
        entry = QME::Importer::Entry.new
        codes = result.xpath("./Description/Code")
        # STDERR.puts "*Result Code: #{codes}"
        found_code = false
        if !codes.empty?
          codes.each do |code|
            normalize_coding_system(code)
            codetext = code.xpath("./CodingSystem")[0].content
            entry.add_code(codetext, code.xpath("./Value")[0].content)
          end
        end
        @patientSummaryReport.results.add_entry(entry)
        test = result.xpath("./Test/Description")
        entry = QME::Importer::Entry.new
        if !test.empty? 
         # STDERR.puts "*Test : #{test}"
         codes = test.xpath("./Code")
         entry = QME::Importer::Entry.new
           if !codes.empty?
             codes.each do |code|
               normalize_coding_system(code)
               codetext = code.xpath("./CodingSystem")[0].content
               entry.add_code(codetext, code.xpath("./Value")[0].content)
             end
           end
         end
         @patientSummaryReport.results.add_entry(entry)
        end
      end
    end
  end

  # if launched as a standalone program, not loaded as a module
  if __FILE__ == $0
    STDERR.puts "GORK"
    entry = QME::Importer::Entry.new
    $uncoded = {}
    doc = CCRscan::CCR.new(ARGV[0], ARGV[1]) 
    doc.process($uncoded)
  end

end