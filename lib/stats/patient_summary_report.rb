module Stats
  # PatientSummaryReport is used to capture an assesment of coded values within both the HITSP C32 and ASTM CCR documents that are to be input 
  # to popHealth
  class PatientSummaryReport
    attr_accessor :allergies, :care_goals, :conditions, :encounters, :immunizations, :medical_equipment,
                  :medications, :procedures, :results, :social_history, :vital_signs

    # Each section is initialized with the appropriate meaningful use (MU) coding systems
    def initialize
        # Initialize the sections of the Patient Summary
        @allergies = PatientSummarySection.new(["RxNorm"])
        @care_goals = PatientSummarySection.new(["SNOMEDCT"])
        @conditions = PatientSummarySection.new(["SNOMEDCT", "ICD9", "ICD10"])
        @encounters = PatientSummarySection.new(["CPT"])
        @immunizations = PatientSummarySection.new(["RxNorm"])
        @medical_equipment = PatientSummarySection.new( ["SNOMEDCT"])
        @medications = PatientSummarySection.new( ["RxNorm"])
        @procedures = PatientSummarySection.new(["SNOMEDCT"])
        @results = PatientSummarySection.new( ["LOINC"])
        @social_history = PatientSummarySection.new( ["SNOMEDCT"])
        @vital_signs = PatientSummarySection.new( ["LOINC"])
    end
  end
end
