module Stats

  # PatientSummaryReport is used to capture an assesment of coded values within both the HITSP C32 
  # and ASTM CCR documents that are to be input to popHealth
  class PatientSummaryReport

    attr_accessor :allergies, :care_goals, :conditions, :encounters, :immunizations, :medical_equipment,
                  :medications, :procedures, :results, :social_history, :vital_signs

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
      @@mu_code_sets[:procedures] = ["CPT","ICD-9-CM","ICD-10-CM","HCPCS"]
      @@mu_code_sets[:results] = ["LOINC","SNOMED-CT"]
      @@mu_code_sets[:social_history] = ["SNOMED-CT"]
      @@mu_code_sets[:vital_signs] = ["ICD-9-CM","ICD-10-CM","SNOMED-CT"]
   end

    def self.from_c32(document)
      psr = PatientSummaryReport.new
      pi = QME::Importer::PatientImporter.instance
      patient_entry_hash = pi.create_c32_hash(document, false)
      patient_entry_hash.each_pair do |section, entry_list|
        pss = PatientSummarySection.new(section, @@mu_code_sets[section])
        entry_list.each do |entry|
          pss.add_entry(entry)
        end
        psr.send("#{section}=", pss)
      end
      psr
    end

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
        psr.send("#{section}=", pss)
      end
      return psr
    end

    def dump
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
      summary_hash
    end

   def unique_mu_entries
        summary_hash = {}
         if(@allergies) 
            summary_hash.merge!(@allergies.unique_mu_entries)
         end
         if(@care_goals)
                summary_hash.merge!(@care_goals.unique_mu_entries)
         end
         if(@conditions)
                summary_hash.merge!(@conditions.unique_mu_entries)
         end
         if (@encounters)
                summary_hash.merge!(@encounters.unique_mu_entries)
         end
         if (@immunizatons)
                summary_hash.merge!(@immunizatons.unique_mu_entries)
         end
         if (@medical_equipment)
                summary_hash.merge!(@medical_equipment.unique_mu_entries)
         end
         if (@medications)
                summary_hash.merge!(@medications.unique_mu_entries)
         end
         if (@procedures)
                summary_hash.merge!(@procedures.unique_mu_entries)
          end
        if (@results)
                summary_hash.merge!(@results.unique_mu_entries)
         end
         if (@social_history)
                summary_hash.merge!(@social_history.unique_mu_entries)
         end
         if (@vital_signs)
                summary_hash.merge!(@vital_signs.unique_mu_entries)
         end
      return summary_hash

   end

    def unique_non_mu_entries
      summary_hash = {}
      if(@allergies) 
        summary_hash.merge!(@allergies.unique_non_mu_entries)
      end
      if(@care_goals)
        summary_hash.merge!(@care_goals.unique_non_mu_entries)
      end
      if(@conditions)
        summary_hash.merge!(@conditions.unique_non_mu_entries)
      end
      if (@encounters)
        summary_hash.merge!(@encounters.unique_non_mu_entries)
      end
      if (@immunizatons)
        summary_hash.merge!(@immunizatons.unique_non_mu_entries)
      end
      if (@medical_equipment)
        summary_hash.merge!(@medical_equipment.unique_non_mu_entries)
      end
      if (@medications)
        summary_hash.merge!(@medications.unique_non_mu_entries)
      end
      if (@procedures)
        summary_hash.merge!(@procedures.unique_non_mu_entries)
      end
      if (@results)
        summary_hash.merge!(@results.unique_non_mu_entries)
      end
      if (@social_history)
        summary_hash.merge!(@social_history.unique_non_mu_entries)
      end
      if (@vital_signs)
        summary_hash.merge!(@vital_signs.unique_non_mu_entries)
      end
      summary_hash
    end

  end

end
