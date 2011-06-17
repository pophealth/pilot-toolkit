
 #C32Preprocessor.
 # Patches certain LOINC codes found in C32 vitals section by adding a translation block to SNOMED-CT
 # SNOMED-CT codes are used by MU CQM, so this allows the coded data to be used by popHealth
   require 'nokogiri'
    require 'json'



module C32Preprocessor
  class PatchCodesDocument
    def initialize (doc,map)
      @doc = doc
      @map = map
      build_id_map
      @vitals_section = C32Preprocessor::PatchCodesSection.new(doc, "vital_signs",map["vital_signs"], @id_map, "//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.14']")
      @results_section = C32Preprocessor::PatchCodesSection.new(doc, "results", map["results"], @id_map,"//cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.15.1'] | //cda:observation[cda:templateId/@root='2.16.840.1.113883.3.88.11.83.15']")
      
    end
    # process
    # input is Nokogiri document
    def process
      @vitals_section.process
      @results_section.process
    end
    
    # Builds a Hash of (tag, value) for all of the referenced and declared identifiers
    # Each of these tags will be queried once during the processing of the file, so doing a hash lookup beats doing an xpath search.
    def build_id_map
      @id_map = {}
      path = "//*[@ID]"
      ids = @doc.xpath(path)
      ids.each do |id|
        tag = id['ID']
        value = id.content
#       STDERR.puts "tag = #{tag} value = #{value}"
        @id_map[tag] = value
      end
    end
    
  end
  
 class PatchCodesSection
   # Initialize a PatchCodesSection
   # @param [Nokogiri::Doc] parsed xml document
   # @param [String] the name of the C32 section
   # @param [Hash] used to translate codes/free-text to codes to insert into C32
   # @param [Hash] used to lookup tags to find string descriptions
   # @param [String] xpath of entries in this section
   # @param [String] xpath for code blocks within an entry
   # @param [String] xpath for descriptions within an entry
   def initialize(doc, section, map, id_map, entry_xpath, code_xpath= "./cda:code", description_xpath = "./cda:code/cda:originalText/cda:reference[@value] | ./cda:text/cda:reference[@value] ")
     @doc = doc
     @section = section
     @map = map
     @id_map = id_map
     @entry_xpath = entry_xpath
     @code_xpath = code_xpath
     @description_xpath = description_xpath
   end
   
   
   # Lookup a tag, return a description
   # @param [String] tag from C32 entry
   # @return [String] the description of the tag
   def lookup_tag(tag)
     value = @id_map[tag]
     # Not sure why, but sometimes the reference is #<Reference> and the ID value is <Reference>, and 
     # sometimes it is #<Reference>.  We look for both.
     if !value and tag[0] == '#'  
       tag = tag[1,tag.length]
       value = @id_map[tag]
     end
     return value
   end

   # Add_translate_block:   add a translate block to an entry
   # @param [Nokogiri::Node] code block node
   # @param [String] code 
   # @param [String] display name
   # @param [String] code system name 
   def add_translate_block(code_element, code, display_name, code_system)
     code_system_oid = QME::Importer::CodeSystemHelper.oid_for_code_system(code_system)
#     STDERR.puts "add_translate_block code_system = #{code_system} code_system_oid: #{code_system_oid} code_system_oid.size"
     Nokogiri::XML::Builder.with(code_element) do |xml|
       xml.translation(:display_name => display_name,
       :codeSystemName => code_system,
       :codeSystem => code_system_oid,
       :code => code)
     end
   end
   
    # Add code translations to coded blocks
    # @param [Nokogiri::Node]   the code element to be inspected and modified
    def add_code_translations(code_element)

     code = code_element['code']
     codesystem = code_element['codeSystemName']
     d = code_element['codeSystem']
#     STDERR.puts "add_code_translations section = #{@section} codesystem #{codesystem} code #{code}"
     # If the map for this section is nil, or there are no entries for this codesystem--> we are done
     if(!@map[codesystem])
        return
      end
     #  Lookup the code
     l = @map[codesystem][code]
#     STDERR.puts "l = #{l}"
     if(l) # If there is a translation, add a translate block
       l.each do | translation |
         add_translate_block(code_element,translation[1], translation[2], translation[0])
        end
     end
   end

   # Add code translations based on descriptions
   # @param [Nokogiri::Node]   the code element to be inspected and modified
   # @param [Nokogiri::Node]   the description to be translated
      def add_codes(entry, description)
        # if the map for this section is nil, or there are no free-text entries -->we are done
       if !@map["FREE-TEXT"]
         return
       end
       # Lookup the tag
       tag = description['value']
       value = lookup_tag(tag)
#       STDERR.puts "FREE-TEXT value #{value}"
       # OK, now we have the description.   Let's look it up.
       l = @map["FREE-TEXT"][value]
       code_element = entry.at_xpath(@code_xpath)
       if(l and code_element)
         # If there is a code block, add a translate block
         # If it doesn't exist, punt
         l.each do | translation |
           STDERR.puts "translation = #{translation.join(',')}"
             add_translate_block(code_element,translation[1], translation[2], translation[0])
         end  
       end
     end
   
     def process
       if(!@map)  # if there are no translations for this section, we are done
         return
       end
#       STDERR.puts "sectionName:   #{@sectionName} xpath: #{@entry_xpath}"
       entries = @doc.xpath(@entry_xpath)
 #      STDERR.puts "Found #{entries.size} elements"
       entries.each do | entry|
         description = entry.at_xpath(@description_xpath)
         STDERR.puts "@description_xpath = #{@description_xpath} description = #{description} codes_xpath = #{@code_xpath}"
         codes = entry.xpath(@code_xpath)
#         STDERR.puts "codes size = #{codes.size}"
         codes.each do |code|
#           STDERR.puts code
           add_code_translations(code)
         end
         add_codes(entry, description)   #see if we can translate from the free text
       end
     end
 
end
end


# if launched as a standalone program, not loaded as a module
if __FILE__ == $0
   require 'nokogiri'
   require 'json'
   require 'qme/importer/code_system_helper'
   if ARGV.size < 3
     STDERR.puts "jruby c32_preprocessor.rb <indir> <outdir> map.json"
     exit
   end

   indir = ARGV[0]
   outdir = ARGV[1]
   mapjson = ARGV[2]

  STDERR.puts "Opening #{indir} for read directory"
    STDERR.puts "Opening #{mapjson} for map"
   STDERR.puts "Opening #{outdir} for write directory" 
   
   map = JSON.parse(File.open(mapjson).read)

    Dir.glob("#{indir}/*.{xml,XML}") do |item|
        infilename = File.basename(item) 
       STDERR.puts infilename

        outfilefp = File.open("#{outdir}/#{infilename}","w")
        infilefp = File.open(item,"r")
        STDERR.puts "Processing #{item}"
       doc = Nokogiri::XML(infilefp) 
       doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
       patch_doc = C32Preprocessor::PatchCodesDocument.new(doc,map)
       patch_doc.process
       outfilefp.puts doc.to_xml
       outfilefp.close
     end 
end 



