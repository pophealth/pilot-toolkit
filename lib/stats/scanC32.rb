require 'quality-measure-engine'
require 'patient_summary_report'
require 'patient_summary_section'
require 'nokogiri'
require 'json'

module C32Scan

  class C32File
    def self.process(infile, summaryfile, mufile, nmufile)
      nmufp = File.open(nmufile,"w")
      mufp = File.open(mufile,"w")
      summaryfp = File.open(summaryfile,"w")
      doc = Nokogiri::XML(File.open(infile) )
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      psr = Stats::PatientSummaryReport.from_c32(doc)
      psr.dump
      summaryfp.puts JSON.pretty_generate(psr.summary)
      nmufp.puts JSON.pretty_generate(psr.unique_non_mu_entries)
      mufp.puts JSON.pretty_generate(psr.unique_mu_entries)
      return psr
    end
  end
  class C32Dir
    @@results = []
    def self.process(indir, outdir)
      @@results = []
      @@outdir = outdir
      Dir.glob("#{indir}/*.{xml,XML}") do |item|
        infilename = File.basename(item) 
        STDERR.puts "infile  = #{item}  infilename = #{infilename}"
        mu = "#{outdir}/#{infilename}.mu"
        nmu = "#{outdir}/#{infilename}.nmu"
        summary = "#{outdir}/#{infilename}.summary"
        STDERR.puts "Processing #{item}"
        @@results << C32Scan::C32File.process(item, summary, mu, nmu)
      end 
    end
      def self.consolidate
        overallfp = File.open("#{@@outdir}/overall.summary","w")
        overallmu = File.open("#{@@outdir}/overall.mu","w")
        overallnmu = File.open("#{@@outdir}/overall.nmu","w")
        
        outpsr = Stats::PatientSummaryReport.new
        @@results.each do |psr |
          outpsr.merge(psr)
        end
        overallfp.puts JSON.pretty_generate(outpsr.summary)
        overallnmu.puts JSON.pretty_generate(outpsr.unique_non_mu_entries)
        overallmu.puts JSON.pretty_generate(outpsr.unique_mu_entries)
        outpsr.dump
        
      end

    end
  end

  # if launched as a standalone program, not loaded as a module
  if __FILE__ == $0

    C32Scan::C32Dir.process(ARGV[0],ARGV[1])
    C32Scan::C32Dir.consolidate
    
  end