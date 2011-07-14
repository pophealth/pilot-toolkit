module Stats

  # PatientSummaryReport is used to capture an assesment of coded values within both the HITSP C32 
  # and ASTM CCR documents that are to be input to popHealth
  class PatientSummaryReport
      attr_accessor :sections
    # Each section is initialized with the appropriate meaningful use (MU) coding systems
    def initialize
      # Initialize the sections of the Patient Summary
      @@mu_code_sets = {}
      @@mu_code_sets[:allergies] = ["RxNorm","SNOMED-CT"]
      @@mu_code_sets[:care_goals] = ["SNOMED-CT"]
      @@mu_code_sets[:conditions] = ["SNOMED-CT", "ICD-9-CM", "ICD-10-CM"]
      @@mu_code_sets[:encounters] = ["CPT"]
      @@mu_code_sets[:immunizations] = ["RxNorm","CVX"]
      @@mu_code_sets[:medical_equipment] = ["SNOMED-CT"]
      @@mu_code_sets[:medications] = ["RxNorm","CVX"]
      @@mu_code_sets[:procedures] = ["CPT","ICD-9-CM","ICD-10-CM","HCPCS","SNOMED-CT"]
      @@mu_code_sets[:results] = ["LOINC","SNOMED-CT"]
      @@mu_code_sets[:social_history] = ["SNOMED-CT"]
      @@mu_code_sets[:vital_signs] = ["ICD-9-CM","ICD-10-CM","SNOMED-CT"]
      
      @sections = {}
   end
   
   # add_section
   # @param [String]  name of the section
   # @param [PatientSummarySection]  associated PatientSummarySection
   #  Note that we add an accessor method when the section is added...this greatly simplifies methods that iterate over all existing sections
   def add_section(section, pss)
     @sections[section] = pss
     self.class.class_eval do
      define_method(section){ @sections[section] }
     end
    end
   
    # from_c32:  read a Nokogiri::Document, and leverage the QME patient importer to create
    # a hash of entries broken down by section.   Pass these through the PatientSummarySection analysis
    # @param [Nokogiri::Document]   source document
    def self.from_c32(document)
      psr = PatientSummaryReport.new
      pi = QME::Importer::PatientImporter.instance
      #patient_entry_hash = pi.create_c32_hash(document, false)
      patient_entry_hash = pi.create_c32_hash(document,false)
      patient_entry_hash.each_pair do |section, entry_list|
        pss = PatientSummarySection.new(section, @@mu_code_sets[section])
        #STDERR.puts section
        entry_list.each do |entry|   #transfer the entries.   Could this be a simple array assignment?
          # STDERR.puts "codes = #{entry.codes}  description = #{entry.description}"
          pss.add_entry(entry)
        end
        psr.add_section(section, pss)
      end
      psr
    end

    # from_c32:  read a Nokogiri::Document, and leverage the CCRScan::CCR to build a hash just like the one created by
    # QME patient importer, a hash of entries broken down by section.   Pass these through the PatientSummarySection analysis
    # @param [Nokogiri::Document]   source document
    def self.from_ccr(document)
      psr = PatientSummaryReport.new
      pi = CCRscan::CCR.new
      patient_entry_hash = pi.create_ccr_hash(document)
      #STDERR.puts patient_entry_hash
      patient_entry_hash.each_pair do |section, entry_list|
        pss = PatientSummarySection.new(section, @@mu_code_sets[section])
        entry_list.each do |entry|
          pss.add_entry(entry)
        end
        psr.add_section(section, pss)
      end
      return psr
    end

    def dump
      @sections.each_pair do |section,pss|
        pss.dump(STDERR)
      end
    end

    def summary
      summary_hash = {}
      @sections.each_pair do |section,pss|
         summary_hash.merge!(pss.summary)
       end
      summary_hash
    end

   def unique_mu_entries
        summary_hash = {}
        @sections.each_pair do |section,pss|
           summary_hash.merge!(pss.unique_mu_entries)
         end
       return summary_hash
   end

   def unique_non_mu_entries
        summary_hash = {}
        @sections.each_pair do |section,pss|
           summary_hash.merge!(pss.unique_non_mu_entries)
         end
       return summary_hash
   end

   def merge(psr)
     @sections.each_pair do |section, pss|
       if(psr.sections[section])  #if we both have a section, merge
         pss.merge(psr.sections[section])
       end
     end
     # if the other guy has sections that we don't...add them
     psr.sections.each_pair do |section,pss1|
       if(!sections[section])
         add_section(section, pss1)
       end
     end
     end

  end

end
