require 'nokogiri'
require 'json'

module C32Deidentify

  class C32FileDeidentify
    def self.process(infile, outfile, givenname,familyname)
      STDERR.puts "infile = #{infile} outfile = #{outfile}"
      outfp = File.open(outfile,"w")
      doc = Nokogiri::XML(File.open(infile) )
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      fixname(doc,givenname,familyname)
      fixaddress(doc)
      outfp.write(doc.to_xml)
    end
    def self.fixname(doc,givenname,familyname)
      given_names = doc.xpath("//cda:patient/cda:name/cda:given")
      family_names = doc.xpath("//cda:patient/cda:name/cda:family")
      given_names.each do |given_name|
        given_name.content = givenname
      end
      family_names.each do |family_name|
        family_name.content = familyname
      end
    end
    def self.fixaddress(doc)
      citys = doc.xpath("//cda:city")
      citys.each do |city|
        city.content = "AnyCity"
      end
      states = doc.xpath("//cda:state")
      states.each do |state|
        state.content = "AnyState"
      end
      sals = doc.xpath("//cda:streetAddressLine")
      sals.each do |sal|
        sal.content = "12345 Main Street"
      end   
      postalCodes = doc.xpath("//cda:postalCode")
      postalCodes.each do |postalCode|
        postalCode.content = "00000"
      end   
      telecoms = doc.xpath("//cda:telecom")
      telecoms.each do |telecom|
        telecom["value"] = "none"
      end   

    end

  end
  class C32DirDeidentify
    @@results = []
    def self.process(indir, outdir)
      @@results = []
      @@outdir = outdir
      patient_num = 0
      Dir.glob("#{indir}/*.{xml,XML}") do |item|
        patient_num += 1
        patient_givenname = "Patient#{patient_num}"
        patient_familyname = "Smith#{patient_num}"
        infile = "#{item}"
        outfile = "#{outdir}/#{patient_givenname}_#{patient_familyname}.XML"
        STDERR.puts "infile  = #{item}  infilename = #{infile} outfile = #{outfile}"

        STDERR.puts "Processing #{item}"
        @@results << C32Deidentify::C32FileDeidentify.process(infile,outfile, patient_givenname, patient_familyname)
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
  C32Deidentify::C32DirDeidentify.process(ARGV[0],ARGV[1])

end