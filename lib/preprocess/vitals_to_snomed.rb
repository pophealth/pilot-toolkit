
 #vitals_to_snomed
 # Patches certain LOINC codes found in C32 vitals section by adding a translation block to SNOMED-CT
 # SNOMED-CT codes are used by MU CQM, so this allows the coded data to be used by popHealth
   require 'nokogiri'
    require 'json'

module C32Preprocessor
 class PatchCodes

 # process_doc
# input is Nokogiri document
  def self.process_doc(doc, map)

    vital_signs_entrys = doc.xpath("//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.14']")
    vital_signs_entrys.each do |entry|
        code_elements = entry.xpath("./cda:code")
        code_elements.each do |code_element|
                code = code_element['code']
                codesystem = code_element['codeSystemName']
                d = code_element['codeSystem']
                l = map["vital_signs"][[codesystem,code]]
#               STDERR.puts "code system #{codesystem} and code #{code } l = #{l}"
                if(l)   # LOINC Code, and we have a translation
                         displayName = l[2]
                         code = l[1]
                         new_code_system = l[0]
                  Nokogiri::XML::Builder.with(code_element) do |xml|
                        xml.translation(:displayName => displayName, 
                                        :codeSystemName => new_code_system, 
                                        :codeSystem => "2.16.840.1.113883.6.96",  # this will need to be a table lookup, or included in the code_to_code_mapping
                                        :code => code)
                  end
                end
         end
     end


  end

 end
end


# if launched as a standalone program, not loaded as a module
if __FILE__ == $0
   require 'nokogiri'
   require 'json'
   if ARGV.size < 2
     STDERR.puts "jruby vitals_to_snomed.rb <indir> <outdir>"
     exit
   end

   map = {
      "vital_signs" =>  {
         ["LOINC", "8462-4"]  => ["SNOMEDCT", "271650006", "blood pressure, diastolic"],
         ["LOINC", "8480-6"]  => ["SNOMEDCT", "271649006", "blood pressure, systolic"],
         ["LOINC", "8302-2"]  => ["SNOMEDCT", "248327008", "height"],
         ["LOINC", "3141-9"]  => ["SNOMEDCT", "107647005", "weight"],
         ["LOINC", "8867-4"]  => ["SNOMEDCT", "366199006", "pulse rate"],
         ["LOINC", "9279-1"]  => ["SNOMEDCT", "366147009", "respiratory rate"],
         ["LOINC", "8310-5"]  => ["SNOMEDCT", "309646008", "temperature"]  
         },
       "medications" =>  {
           ["Multum", "12345"]  => ["RxNorm",  "1234", "aspirin"]
         }
     }

   indir = ARGV[0]
   outdir = ARGV[1]

  STDERR.puts "Opening #{indir} for read"
   STDERR.puts "Opening #{outdir} for write" 

    Dir.glob("#{indir}/*.{xml,XML}") do |item|
        infilename = File.basename(item) 
       STDERR.puts infilename

        outfilefp = File.open("#{outdir}/#{infilename}","w")
        infilefp = File.open(item,"r")
        STDERR.puts "Processing #{item}"
       doc = Nokogiri::XML(infilefp) 
       doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
       C32Preprocessor::PatchCodes.process_doc(doc,map)
       outfilefp.puts doc.to_xml
       outfilefp.close
     end 
end 



