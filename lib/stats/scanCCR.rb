

module CCRscan

  class CCRFile
     def self.process(infile, summaryfile, mufile, nmufile)

STDERR.puts "CCRFile.process = #{infile}"
       doc = Nokogiri::XML(File.open(infile) ) 
       doc.root.add_namespace_definition('ccr', "urn:astm-org:CCR")
       
       nmufp = File.open(nmufile,"w")
       mufp = File.open(mufile,"w")
       summaryfp = File.open(summaryfile,"w")

       psr = Stats::PatientSummaryReport.from_ccr(doc)
       psr.dump
       summaryfp.puts JSON.pretty_generate(psr.summary)
       nmufp.puts JSON.pretty_generate(psr.unique_non_mu_entries)
       mufp.puts JSON.pretty_generate(psr.unique_mu_entries)
       return psr
     end
   end
   class CCRDir
     @@results = []
     def self.process(indir, outdir)
STDERR.puts "CCRDir.process = #{indir}" 
      @@results = []
       @@outdir = outdir
       Dir.glob("#{indir}/*.{xml,XML}") do |item|
         infilename = File.basename(item) 
         STDERR.puts "infile  = #{item}  infilename = #{infilename}"
         mu = "#{outdir}/#{infilename}.mu"
         nmu = "#{outdir}/#{infilename}.nmu"
         summary = "#{outdir}/#{infilename}.summary"
         STDERR.puts "Processing #{item}"
         @@results << CCRscan::CCRFile.process(item, summary, mu, nmu)
       end 
     end
       def self.consolidate
         overallfp = File.open("#{@@outdir}/overall.summary","w")
         overallmu = File.open("#{@@outdir}/overall.mu","w")
         overallnmu = File.open("#{@@outdir}/overall.nmu","w")

         outpsr = Stats::PatientSummaryReport.new
         @@results.each do |psr |
           outpsr.merge(psr)
         end
         overallfp.puts JSON.pretty_generate(outpsr.summary)
         overallnmu.puts JSON.pretty_generate(outpsr.unique_non_mu_entries)
         overallmu.puts JSON.pretty_generate(outpsr.unique_mu_entries)
         outpsr.dump
       end

     end
  class CCR

    def initialize()
      @ccr_hash = {}
      @sections = {:conditions        => "//ccr:Problems/ccr:Problem",
                   :encounters        => "//ccr:Encounters/ccr:Encounter",
                   :procedures        => "//ccr:Procedures/ccr:Procedure",
                   :care_goals        => "//ccr:Goals/ccr:Goal",
                   :social_history    => "//ccr:SocialHistory/ccr:SocialHistoryElement",
                   :medical_equipment => "//ccr:MedicalEquipment/ccr:Equipment",
                   :allergies         => "//ccr:Alerts/ccr:Alert",           # special handling for Description
                   :vital_signs       => "//ccr:VitalSigns/ccr:Result",      # special handling for ./Test/Description
                   :results           => "//ccr:Results/ccr:Result",         # special handling for ./test...same as for vital_signs
                   :medications       => "//ccr:Medications/ccr:Medication", # special handling for productName, brandName
                   :immunizations     => "//ccr:Immunizations/ccr:Immunization" # special handling for productName, brandName
}
    end

    def create_ccr_hash(doc)
      # This should be generalized to use Xpath expressions for the different sections

    # These all follow the same pattern
     process_section(:conditions,        doc)
      process_section(:encounters,        doc)
      process_section(:procedures,        doc)
      process_section(:care_goals,        doc)
      process_section(:social_history,    doc)
      process_section(:medical_equipment, doc)
      process_section(:allergies,        doc)
     # These are special
      process_vital_signs(:vital_signs,   doc)   # Note that this is special!
      process_vital_signs(:results,       doc)   # Note that this is special!
      process_medications(:medications,   doc)   # Note that this is special!
      process_medications(:immunizations, doc)   # Note that this is special!
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
      codingsystem = lookup[code.at_xpath('./ccr:CodingSystem').content.downcase]
      if(codingsystem)
        code.at_xpath('./ccr:CodingSystem').content = codingsystem
      end
    end

    # Add the codes from a <Code> block to an Entry
    def process_codes(node, entry)
      codes = node.xpath("./ccr:Description/ccr:Code")
      desctext = node.at_xpath("./ccr:Description/ccr:Text").content
      entry.description = desctext
      if codes.size > 0 
        found_code = true
        codes.each do |code|
          normalize_coding_system(code)
          codetext = code.at_xpath("./ccr:CodingSystem").content
          entry.add_code(code.at_xpath("./ccr:Value").content, codetext)
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
          codetext = code.at_xpath("./ccr:CodingSystem").content
          entry.add_code(code.at_xpath("./ccr:Value").content, codetext)
        end
      end
    end

    # Process most of the sections.  Some sections require special handling.
    def process_section(section_name, doc)
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
          productNameText = productName.at_xpath("./ccr:Text")
          brandNameText = brandName.at_xpath("./ccr:Text") 
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
  require 'quality-measure-engine'
  require_relative 'patient_summary_report'
  require_relative 'patient_summary_section'
  require 'nokogiri'
  require 'json'

  CCRscan::CCRDir.process(ARGV[0],ARGV[1])
  CCRscan::CCRDir.consolidate
  
end