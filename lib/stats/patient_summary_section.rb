# Stats object collects statistics regarding the content of a single section of a Patient Summary (C32 or CCR)
# As entries are added to the section, they are classified as coded vs uncoded, and within the coded as MU 
# (meaningful use) coded, or alien (not the relevant code set for meaningful use). 
module Stats

  class PatientSummarySection

    attr_accessor :mu_coded_entries, :alien_coded_entries, :uncoded_entries
    attr_reader :entries

    #  Initializing a PatientSummarySection requires an array of valid MU code systems for entries to be recorded
    def initialize(mu_code_systems)
      @mu_code_systems_found = {}
      @alien_code_systems_found = {}
      @uncoded_entries = []
      @mu_coded_entries = []
      @alien_coded_entries = []
      @mu_code_systems = mu_code_systems
      @entries = []
    end

    def num_uncoded_entries
      uncoded_entries.size
    end

    def num_mu_coded_entries 
      mu_coded_entries.size
    end

    def num_alien_coded_entries
      alien_coded_entries.size
    end

    def num_coded_entries
      mu_coded_entries.size + alien_coded_entries.size
    end

    def alien_code_systems_found
      @alien_code_systems_found.keys
    end

    def mu_code_systems_found
      @mu_code_systems_found.keys
    end

    def add_entry(entry)
      mu_code_found = false
      @entries << entry
      if entry.codes.empty?
        @uncoded_entries << entry
      else
        entry.codes.each_pair do |codeset, values|
          if @mu_code_systems.include?(codeset)
            mu_code_found = true;
            @mu_code_systems_found[codeset] = true
          else
            @alien_code_systems_found[codeset] = true
          end
        end
        if mu_code_found
          @mu_coded_entries << entry    # If an entry has both mu codes and alien codes, it is classified as mu_coded
        else
          @alien_coded_entries << entry # contains only non-mu codes
        end
      end
    end
  end
end

# if launched as a standalone program, not loaded as a module
if __FILE__ == $0
   section = Stats::PatientSummarySection.new(["ICD9","ICD10","SNOMEDCT"])
   entry = QME::Importer::Entry.new
   entry.add_code(32000, "ICD9")
   entry.add_code(32001,"ICD9")
   entry.add_code(32000, "ICD10")
   entry.add_code(32001,"ICD10")
   entry.add_code(1,"GORK")
   section.add_entry(entry)
   STDERR.puts "aliens:  #{section.num_alien_coded_entries} #{section.alien_code_systems_found}"
   STDERR.puts "mu:      #{section.num_mu_coded_entries}   #{section.mu_code_systems_found}"   
   STDERR.puts "uncoded: #{section.num_uncoded_entries}"
   STDERR.puts "coded:   #{section.num_coded_entries}"
end