module Stats
  class PatientSummarySection
    def initialize(mu_code_systems)
      @num_coded_entries = 0
      @num_uncoded_entries = 0
      @num_alien_coded_entries = 0
      @mu_code_systems_found = []
      @alien_code_systems_found = []
      @entries = []
      @mu_code_systems = mu_code_systems
    end
    
    def add_entry(entry)
      @entries << entry
    end
  end
end