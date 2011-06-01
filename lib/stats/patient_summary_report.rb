module Stats
  # PatientSummaryReport is used to capture an assesment of coded values within both the HITSP C32 and ASTM CCR documents that are to be input 
  # to popHealth
  class PatientSummaryReport
    attr_accessor :allergies, :care_goals, :conditions, :encounters, :immunizations, :medical_equipment,
                  :medications, :procedures, :results, :social_history, :vital_signs

    @mu_code_sets = {}
    @mu_code_sets[:allergies] = ["RxNorm","SNOMED-CT"]
    @mu_code_sets[:care_goals] = ["SNOMED-CT"]
    @mu_code_sets[:conditions] = ["SNOMED-CT", "ICD-9-CM", "ICD-10-CM"]
    @mu_code_sets[:encounters] = ["CPT"]
    @mu_code_sets[:immunizations] = ["RxNorm","CVX"]
    @mu_code_sets[:medical_equipment] = ["SNOMED-CT"]
    @mu_code_sets[:medications] = ["RxNorm","CVX"]
    @mu_code_sets[:procedures] = ["CPT","ICD-9-CM","ICD-10-CM","HCPCS"]
    @mu_code_sets[:results] = ["LOINC","SNOMED-CT"]
    @mu_code_sets[:social_history] = ["SNOMED-CT"]
    @mu_code_sets[:vital_signs] = ["ICD-9-CM","ICD-10-CM","SNOMED-CT"]

    def self.from_c32(document)
      psr = PatientSummaryReport.new
      pi = QME::Importer::PatientImporter.instance
      patient_entry_hash = pi.create_c32_hash(document)
      patient_entry_hash.each_pair do |section, entry_list|
        pss = PatientSummarySection.new(@mu_code_sets[section])
        entry_list.each {|entry| pss.add_entry(entry)}
        psr.send("#{section}=", pss)
      end

      psr
    end

  end
end
