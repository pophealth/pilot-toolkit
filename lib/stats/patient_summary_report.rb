require 'quality-measure-engine'
require 'patient_summary_section'


module Stats
  # PatientSummaryReport is used to capture an assesment of coded values within both the HITSP C32 and ASTM CCR documents that are to be input 
  # to popHealth
  class PatientSummaryReport
    attr_accessor :allergies, :care_goals, :conditions, :encounters, :immunizations, :medical_equipment,
                  :medications, :procedures, :results, :social_history, :vital_signs

<<<<<<< HEAD
    # Each section is initialized with the appropriate meaningful use (MU) coding systems
    def initialize
        # Initialize the sections of the Patient Summary
        @allergies = PatientSummarySection.new(["RxNorm","SNOMEDCT"])
        @care_goals = PatientSummarySection.new(["SNOMEDCT"])
        @conditions = PatientSummarySection.new(["SNOMEDCT", "ICD9", "ICD10"])
        @encounters = PatientSummarySection.new(["CPT"])
        @immunizations = PatientSummarySection.new(["RxNorm","CVX"])
        @medical_equipment = PatientSummarySection.new( ["SNOMEDCT"])
        @medications = PatientSummarySection.new( ["RxNorm","CVX"])
        @procedures = PatientSummarySection.new(["CPT","ICD9","ICD10","HCPCS"])
        @results = PatientSummarySection.new( ["LOINC","SNOMEDCT"])
        @social_history = PatientSummarySection.new( ["SNOMEDCT"])
        @vital_signs = PatientSummarySection.new( ["ICD9","ICD10","SNOMEDCT"])
=======
    @mu_code_sets = {}
    @mu_code_sets[:allergies] = ["RxNorm","SNOMEDCT"]
    @mu_code_sets[:care_goals] = ["SNOMEDCT"]
    @mu_code_sets[:conditions] = ["SNOMEDCT", "ICD9", "ICD10"]
    @mu_code_sets[:encounters] = ["CPT"]
    @mu_code_sets[:immunizations] = ["RxNorm","CVX"]
    @mu_code_sets[:medical_equipment] = ["SNOMEDCT"]
    @mu_code_sets[:medications] = ["RxNorm","CVX"]
    @mu_code_sets[:procedures] = ["CPT","ICD9","ICD10","HCPCS"]
    @mu_code_sets[:results] = ["LOINC","SNOMEDCT"]
    @mu_code_sets[:social_history] = ["SNOMEDCT"]
    @mu_code_sets[:vital_signs] = ["ICD9","ICD10","SNOMEDCT"]

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
>>>>>>> a8064b05f0724cafc76417063faf3565a9892fef
    end

  end
end
