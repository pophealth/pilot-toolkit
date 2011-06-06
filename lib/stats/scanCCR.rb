
# CCRscan
#  This module includes code for doing a quick and dirty parse of a CCR file, to produce a list of entries similar to those produced by the C32
#  parser.

module CCRscan
 class CCR

# initialize -- open the XML file and parse
    def initialize()
        @ccr_hash = {}
        @sections = { :conditions  => "//Problems/Problem",
                      :encounters =>  "//Encounters/Encounter",
                      :medications => "//Medications/Medication",    #special handling for productName, brandName
                      :allergies   => "//Alerts/Alert",              #special handling for Description
                      :procedures => "//Procedures/Procedure",
                      :vital_signs => "//VitalSigns/Result",            #special handling for ./Test/Description
                      :results     => "//Results/Result",                #special handling for ./test...same as for vital_signs
                      :care_goals => "//Goals/Goal",
                      :social_history => "//SocialHistory/SocialHistoryElement",
                      :medical_equipment => "//MedicalEquipment/Equipment"
       }
    end

    def create_ccr_hash(doc)
        @doc = doc

        process_section(:conditions ) #-> problems
        process_section(:encounters) #-> encounters
        process_section(:procedures) #-> procedures
        process_section(:care_goals) #-> care_goals ...is there such a section?
        process_section(:social_history) # -> social_history
        process_section(:medical_equipment) #-> medial_equipment...is there such a section
        process_section(:allergies) #-> alerts...is there such a section
        process_vital_signs (:vital_signs)  #-> vital_signs
        process_vital_signs (:results)  #-> results
        process_medications(:medications)#-> medications

      return @ccr_hash
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
             "rxnorm" => "RxNorm",
             "icd9-cm" => "ICD-9-CM",
             "icd9" => "ICD-9-CM"
        }
        codingsystem = lookup[code.xpath('./CodingSystem')[0].content.downcase]
        if(codingsystem)
                code.xpath('./CodingSystem')[0].content = codingsystem
        end
    end

def process_codes(node,entry)

        codes = node.xpath("./Description/Code")
#        STDERR.puts "codes.size = #{codes.size}"
        desctext = node.xpath("./Description/Text")[0].content
        entry.description = desctext
        if codes.size > 0 
              found_code = true
              codes.each do | code | 
              normalize_coding_system(code)
              codetext = code.xpath("./CodingSystem")[0].content
              entry.add_code(code.xpath("./Value")[0].content, codetext)
           end
        end
end

def process_product_codes(node,entry)

        codes = node.xpath("./Code")
#        STDERR.puts "codes.size = #{codes.size}"
        if codes.size > 0 
              found_code = true
              codes.each do | code | 
              normalize_coding_system(code)
              codetext = code.xpath("./CodingSystem")[0].content
              entry.add_code(code.xpath("./Value")[0].content, codetext)
           end
        end
end

def process_section(section_name)
#     STDERR.puts "process_section #{section_name} starting at #{@sections[section_name]}"
     entries = @doc.xpath(@sections[section_name])
     if(entries.size == 0)
        return
     end

     @ccr_hash[ section_name] = []
     entries.each do | e | 
         entry = QME::Importer::Entry.new
         process_codes(e,entry)
         @ccr_hash[ section_name ] << entry
     end

end


def process_vital_signs (section_name)
#     STDERR.puts "process_section #{section_name} starting at #{@sections[section_name]}"
      results = @doc.xpath(@sections[section_name])
      if (results.size == 0)
        return
      end
      @ccr_hash[section_name] = []
      results.each do | result | 
         entry = QME::Importer::Entry.new
         process_codes(result, entry)

         test = result.xpath("./Test")
#        STDERR.puts "test.size = #{test.size}"
         if (test.size > 0 && test.xpath("./Description/Text").size > 0)
                
                process_codes(test,entry)   # add them to the entry
         end
         @ccr_hash[section_name] << entry 
      end
 end


def process_medications (section_name)
#     STDERR.puts "process_section #{section_name} starting at #{@sections[section_name]}"
      meds = @doc.xpath(@sections[section_name])
      if(meds.size == 0)
        return
      end
        @ccr_hash[section_name] = []
        #STDERR.puts "meds = #{meds.size}    #{meds}"
      meds.each do | med | 
         entry = QME::Importer::Entry.new
         products = med.xpath("./Product")
#        STDERR.puts "products = #{products.size} #{products}"
         products.each do | product |
             #STDERR.puts product
             productName = product.xpath("./ProductName")
             brandName = product.xpath("./BrandName")
             productNameText = productName.xpath("./Text")[0]
             brandNameText = brandName.xpath("./Text")[0] 
             entry.description = productNameText.content
             process_product_codes(productName, entry)    #we throw any codes found within the productName and brandName into the same entry
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
require 'patient_summary_report'
require 'nokogiri'
require 'json'

#  STDERR.puts "GORK"
  ccrFilePath = ARGV[0]
  doc = Nokogiri::XML(File.open(ccrFilePath) ) 

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

