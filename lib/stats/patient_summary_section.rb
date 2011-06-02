# Stats object collects statistics regarding the content of a single section of a Patient Summary (C32 or CCR)
# As entries are added to the section, they are classified as coded vs uncoded, and within the coded as MU (meaningful use) coded, or alien (not the 
# relevant code set for meaningful use. 

require 'quality-measure-engine'

module Stats
  class PatientSummarySection
    attr_accessor :mu_coded_entries, :alien_coded_entries, :uncoded_entries
    attr_reader :entries
#  Initializing a PatientSummarySection requires an array of valid MU code systems for entries to be recorded

    def initialize(name, mu_code_systems)
      @name = name
      @mu_code_systems_found = {}
      @alien_code_systems_found = {}
      @uncoded_entries = []
      @mu_coded_entries = []
      @alien_coded_entries = []
      @mu_code_systems = mu_code_systems
    end
    
#
    def summary
       results = { @name => { "entries" => "#{num_coded_entries + num_uncoded_entries}",
                             "mu code systems" => @mu_code_systems,
                             "coded entries" => num_coded_entries,
                             "mu coded entries" => num_mu_coded_entries,
                             "mu code systems in use" => mu_code_systems_found,
                             "non-mu coded entries" =>num_alien_coded_entries,
                             "non-mu code systems in use" => alien_code_systems_found
                            }
                  }
        return results
     end

    def dump(outfp)
   outfp.puts "Section #{@name}:   mu_code_systems = #{@mu_code_systems.join(',')}"
   outfp.puts "\tEntries: #{num_coded_entries + num_uncoded_entries}, #{num_coded_entries} coded"
    if(num_alien_coded_entries > 0)
        outfp.puts "\taliens: #{num_alien_coded_entries} #{alien_code_systems_found}"
    end
    if(num_mu_coded_entries > 0)
        andaliens = ""
        if(alien_code_systems_found.size > 0)
             andaliens = "and #{alien_code_systems_found}"
        end
        outfp.puts "\tmu:     #{num_mu_coded_entries}   #{mu_code_systems_found} #{andaliens}"  
    end
   end
#
    def num_uncoded_entries
        return uncoded_entries.size
    end
#
    def num_mu_coded_entries 
        return mu_coded_entries.size
    end
#
    def num_alien_coded_entries
        return alien_coded_entries.size
    end
#
    def num_coded_entries
        return mu_coded_entries.size + alien_coded_entries.size
    end
#
    def alien_code_systems_found
        return @alien_code_systems_found.keys
    end
#
    def mu_code_systems_found
        return @mu_code_systems_found.keys
    end
#
    def add_entry(entry)
        STDERR.puts "add_entry -- codes = #{entry.codes.size}"
      mu_code_found = false;

      if (entry.codes.size  > 0)
      entry.codes.each_pair do |codeset, values|
          STDERR.puts "codeset = #{codeset}  values = #{values}"
        if(@mu_code_systems.to_set.member?(codeset))
           mu_code_found = true;
           @mu_code_systems_found[codeset] = true
        else
          # add to alien_code_systems_found
           @alien_code_systems_found[codeset] = true
        end
       end
        if(mu_code_found) 
          @mu_coded_entries << entry    # If an entry has both mu codes and alien codes, it is classified as mu_coded
        else
          @alien_coded_entries << entry  # contains only non-mu codes
        end
      else
        @uncoded_entries << entry
      end
     end
  
    end
  end


# if launched as a standalone program, not loaded as a module
if __FILE__ == $0

   section = Stats::PatientSummarySection.new("junk",["ICD9","ICD10","SNOMEDCT"])
   entry = QME::Importer::Entry.new
   entry.add_code(32000, "ICD9")
   entry.add_code(32001,"ICD9")
   entry.add_code(32000, "ICD10")
   entry.add_code(32001,"ICD10")
   entry.add_code(1,"GORK")
   section.add_entry(entry)
   section.dump(STDERR)
   STDERR.puts section.summary


end
