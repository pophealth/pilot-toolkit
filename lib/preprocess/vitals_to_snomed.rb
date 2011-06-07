
 #vitals_to_snomed
 # Patches certain LOINC codes found in C32 vitals section by adding a translation block to SNOMED-CT
 # SNOMED-CT codes are used by MU CQM, so this allows the coded data to be used by popHealth
   require 'nokogiri'
    require 'json'

module C32Preprocessor
 class PatchVitals

    def initialize
      @loinc_to_snomed = {
              "8462-4"  => {  "snomedcode" => 271650006,   "description" => "blood pressure, diastolic" },
              "8480-6"  => {  "snomedcode" => 271649006,   "description" => "blood pressure, systolic" },
              "8302-2"  => {  "snomedcode" => 248327008,   "description" => "height" },
              "3141-9"  => {  "snomedcode" => 107647005,   "description" => "weight" },
              "8867-4"  => {  "snomedcode" => 366199006,   "description" => "pulse rate" },
              "9279-1"  => {  "snomedcode" => 366147009,   "description" => "respiratory rate" },
              "8310-5"  => {  "snomedcode" => 309646008,   "description" => "temperature" },
      }
    end

# process_doc
# input is Nokogiri document
  def process_doc(doc)

    vital_signs_entrys = doc.xpath("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.14']")
    vital_signs_entrys.each do |entry|
        code_elements = entry.xpath("./cda:code")
        code_elements.each do |code_element|
                code = code_element['code']
                codesystem = code_element['codeSystem']
                d = code_element['codeSystem']
                l = @loinc_to_snomed[code]
               STDERR.puts "code system #{codesystem} and code #{code }"
                if(codesystem == "2.16.840.1.113883.6.1" and l)   # LOINC Code, and we have a translation
                         displayName = l['description']
                         snomedcode = l['snomedcode']
                  Nokogiri::XML::Builder.with(code_element) do |xml|
                        xml.translation(:displayName => displayName, 
                                        :codeSystemName => "SNOMEDCT", 
                                        :codeSystem => "2.16.840.1.113883.6.96", 
                                        :code => snomedcode)
                  end
                end
         end
     end


  end

 end
end


# if launched as a standalone program, not loaded as a module
if __FILE__ == $0

   if ARGV.size < 2
     STDERR.puts "jruby vitals_to_snomed.rb <indir> <outdir>"
     exit
   end

   indir = ARGV[0]
   outdir = ARGV[1]

  STDERR.puts "Opening #{indir} for read"
   STDERR.puts "Opening #{outdir} for write" 

    Dir.glob("#{indir}/*.{xml,XML}") do |item|
        infilename = File.basename(item) 
       STDERR.puts infilename
        patcher = C32Preprocessor::PatchVitals.new
        outfilefp = File.open("#{outdir}/#{infilename}","w")
        infilefp = File.open(item,"r")
        STDERR.puts "Processing #{item}"
       doc = Nokogiri::XML(infilefp) 
       doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
       patcher.process_doc(doc)
       outfilefp.puts doc.to_xml
       outfilefp.close
     end 
end 



