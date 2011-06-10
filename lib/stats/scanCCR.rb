#require 'quality-measure-engine'
#require 'patient_summary_report'
#require 'nokogiri'
#require 'json'

#$coded_values = {}
#$uncoded = {}

module CCRscan

  class CCR

    def initialize()
      @ccr_hash = {}
      @sections = {:conditions        => "//ccr:Problems/ccr:Problem",
                   :encounters        => "//ccr:Encounters/ccr:Encounter",
                   :medications       => "//ccr:Medications/ccr:Medication", # special handling for productName, brandName
                   :allergies         => "//ccr:Alerts/ccr:Alert",           # special handling for Description
                   :procedures        => "//ccr:Procedures/ccr:Procedure",
                   :vital_signs       => "//ccr:VitalSigns/ccr:Result",      # special handling for ./Test/Description
                   :results           => "//ccr:Results/ccr:Result",         # special handling for ./test...same as for vital_signs
                   :care_goals        => "//ccr:Goals/ccr:Goal",
                   :social_history    => "//ccr:SocialHistory/ccr:SocialHistoryElement",
                   :medical_equipment => "//ccr:MedicalEquipment/ccr:Equipment"}
    end

    def create_ccr_hash(doc)
      process_section(:conditions,        doc)
      process_section(:encounters,        doc)
      process_section(:procedures,        doc)
      process_section(:care_goals,        doc)
      process_section(:social_history,    doc)
      process_section(:medical_equipment, doc)
      process_section(:allergies,         doc)
      process_vital_signs(:vital_signs,   doc)
      process_vital_signs(:results,       doc)
      process_medications(:medications,   doc)
      @ccr_hash
    end

    # normalize_coding_system attempts to simplify analysis of the XML doc by 
    # normalizing the names of the coding systems. Input is a single "Code" node
    # in the tree, and the side effect is to edit the CodingSystem subnode.
    def normalize_coding_system(code)
      lookup = {
        "lnc"       => "LOINC",
        "loinc"     => "LOINC",
        "cpt"       => "CPT",
        "cpt-4"     => "CPT",
        "snomedct"  => "SNOMEDCT",
        "snomed-ct" => "SNOMEDCT",
        "rxnorm"    => "RxNorm",
        "icd9-cm"   => "ICD-9-CM",
        "icd9"      => "ICD-9-CM"
      }
      codingsystem = lookup[code.xpath('./ccr:CodingSystem')[0].content.downcase]
      if(codingsystem)
        code.xpath('./ccr:CodingSystem')[0].content = codingsystem
      end
    end

    # Add the codes from a <Code> block to an Entry
    def process_codes(node, entry)
      codes = node.xpath("./ccr:Description/ccr:Code")
      desctext = node.xpath("./ccr:Description/ccr:Text")[0].content
      entry.description = desctext
      if codes.size > 0 
        found_code = true
        codes.each do |code|
          normalize_coding_system(code)
          codetext = code.xpath("./ccr:CodingSystem")[0].content
          entry.add_code(code.xpath("./ccr:Value")[0].content, codetext)
        end
      end
    end

    # Add the codes from a <Product> block subsection to an Entry
    def process_product_codes(node, entry)
      codes = node.xpath("./ccr:Code")
      if codes.size > 0
        found_code = true
        codes.each do |code|
          normalize_coding_system(code)
          codetext = code.xpath("./ccr:CodingSystem")[0].content
          entry.add_code(code.xpath("./ccr:Value")[0].content, codetext)
        end
      end
    end

    # Process most of the sections.  Some sections require special handling.
    def process_section(section_name, doc)
      #STDERR.puts "process_section #{section_name} starting at #{@sections[section_name]}"
      entries = doc.xpath(@sections[section_name])
      if(entries.size == 0)
        return
      end
      @ccr_hash[section_name] = []
      entries.each do | e |
        entry = QME::Importer::Entry.new
        process_codes(e, entry)
        @ccr_hash[section_name] << entry
      end
    end

    # Special handling for the vital signs section
    def process_vital_signs(section_name, doc)
      #STDERR.puts "process_section #{section_name} starting at #{@sections[section_name]}"
      results = doc.xpath(@sections[section_name])
      if (results.size == 0)
        return
      end
      @ccr_hash[section_name] = []
      results.each do |result|
        entry = QME::Importer::Entry.new
        process_codes(result, entry)
        test = result.xpath("./ccr:Test")
        if (test.size > 0 && test.xpath("./ccr:Description/ccr:Text").size > 0)               
          process_codes(test,entry)   # add them to the entry
        end
        @ccr_hash[section_name] << entry
      end
    end

    # Special handling for the medications section
    def process_medications (section_name, doc)
      #STDERR.puts "process_section #{section_name} starting at #{@sections[section_name]}"
      meds = doc.xpath(@sections[section_name])
      if(meds.size == 0)
        return
      end
      @ccr_hash[section_name] = []
      meds.each do | med | 
        entry = QME::Importer::Entry.new
        products = med.xpath("./ccr:Product")
        products.each do | product |
          productName = product.xpath("./ccr:ProductName")
          brandName = product.xpath("./ccr:BrandName")
          productNameText = productName.xpath("./ccr:Text")[0]
          brandNameText = brandName.xpath("./ccr:Text")[0] 
          entry.description = productNameText.content
          process_product_codes(productName, entry) # we throw any codes found within the productName and brandName into the same entry
          process_product_codes(brandName, entry)
        end
        @ccr_hash[section_name] << entry
      end
    end
  end
end

# if launched as a standalone program, not loaded as a module
if __FILE__ == $0
  ccrFilePath = ARGV[0]
  doc = Nokogiri::XML(File.open(ccrFilePath) ) 
  psr = Stats::PatientSummaryReport.from_ccr(doc)
  psr.dump
  STDERR.puts JSON.pretty_generate(psr.summary)
  ccr = CCRscan::CCR.new
  hash = ccr.create_ccr_hash (doc)
  hash.each_pair do |section, entries|
    STDERR.puts "Section #{section} with #{entries.size} entries"
    entries.each do | entry |
      STDERR.puts "\tEntry #{entry.description}"
      entry.codes.each_pair do |codeset, codes|
        STDERR.puts "\t\t#{codeset}  #{codes.join(',')}"
      end
    end
  end
end