require 'quality-measure-engine'
require 'patient_summary_section'
require 'ccrscan'


module Stats
  # PatientSummaryReport is used to capture an assesment of coded values within both the HITSP C32 and ASTM CCR documents that are to be input 
  # to popHealth
  class PatientSummaryReport
    attr_accessor :allergies, :care_goals, :conditions, :encounters, :immunizations, :medical_equipment,
                  :medications, :procedures, :results, :social_history, :vital_signs

    # Each section is initialized with the appropriate meaningful use (MU) coding systems
    def initialize
        # Initialize the sections of the Patient Summary
      @@mu_code_sets = {}
      @@mu_code_sets[:allergies] = ["RxNorm","SNOMEDCT"]
      @@mu_code_sets[:care_goals] = ["SNOMEDCT"]
      @@mu_code_sets[:conditions] = ["SNOMEDCT", "ICD-9-CM", "ICD-10-CM"]
      @@mu_code_sets[:encounters] = ["CPT"]
      @@mu_code_sets[:immunizations] = ["RxNorm","CVX"]
      @@mu_code_sets[:medical_equipment] = ["SNOMEDCT"]
      @@mu_code_sets[:medications] = ["RxNorm","CVX"]
      @@mu_code_sets[:procedures] = ["CPT","ICD-9-CM","ICD-10-CM","HCPCS"]
      @@mu_code_sets[:results] = ["LOINC","SNOMEDCT"]
      @@mu_code_sets[:social_history] = ["SNOMEDCT"]
      @@mu_code_sets[:vital_signs] = ["ICD-9-CM","ICD-10-CM","SNOMEDCT"]
   end

    def self.from_c32(document)
      psr = PatientSummaryReport.new
      pi = QME::Importer::PatientImporter.instance
      patient_entry_hash = pi.create_c32_hash(document)
      patient_entry_hash.each_pair do |section, entry_list|
        pss = PatientSummarySection.new(section, @@mu_code_sets[section])
        entry_list.each {|entry| pss.add_entry(entry)}
        psr.send("#{section}=", pss)
      end
     psr
    end
   def self.from_ccr(document)
      psr = PatientSummaryReport.new
      pi = CCRscan::CCR.new
      patient_entry_hash = pi.create_ccr_hash(document)
      STDERR.puts patient_entry_hash
      patient_entry_hash.each_pair do |section, entry_list|
        pss = PatientSummarySection.new(section, @@mu_code_sets[section])
        entry_list.each {|entry| pss.add_entry(entry)}
        psr.send("#{section}=", pss)
      end

      psr
    end

   ### THERE HAS GOT TO BE A BETTER WAY TO DO THIS!
   def dump
         STDERR.puts "***BEGIN DUMP***"
         if(@allergies) 
            @allergies.dump(STDERR)
         end
         if(@care_goals)
                @care_goals.dump(STDERR)
         end
         if(@conditions)
                @conditions.dump(STDERR)
         end
         if (@encounters)
                @encounters.dump(STDERR)
         end
         if (@immunizatons)
         @immunizatons.dump(STDERR)
         end
         if (@medical_equipment)
         @medical_equipment.dump(STDERR)
         end
         if (@medications)
         @medications.dump(STDERR)
         end
         if (@procedures)
         @procedures.dump(STDERR)
          end
        if (@results)
         @results.dump(STDERR)
         end
         if (@social_history)
         @social_history.dump(STDERR)
         end
         if (@vital_signs)
         @vital_signs.dump(STDERR)
         end
         STDERR.puts "***END DUMP***"
   end

   def summary
        summary_hash = {}
         if(@allergies) 
            summary_hash.merge!(@allergies.summary)
         end
         if(@care_goals)
                summary_hash.merge!(@care_goals.summary)
         end
         if(@conditions)
                summary_hash.merge!(@conditions.summary)
         end
         if (@encounters)
                summary_hash.merge!(@encounters.summary)
         end
         if (@immunizatons)
                summary_hash.merge!(@immunizatons.summary)
         end
         if (@medical_equipment)
                summary_hash.merge!(@medical_equipment.summary)
         end
         if (@medications)
                summary_hash.merge!(@medications.summary)
         end
         if (@procedures)
                summary_hash.merge!(@procedures.summary)
          end
        if (@results)
                summary_hash.merge!(@results.summary)
         end
         if (@social_history)
                summary_hash.merge!(@social_history.summary)
         end
         if (@vital_signs)
                summary_hash.merge!(@vital_signs.summary)
         end
      return summary_hash

   end
end
end
