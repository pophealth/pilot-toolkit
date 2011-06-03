module Validation

  class ValidatorRegistry

    def self.c32_schematron_validator
      @c32_schematron_validator ||= SchematronValidator::CompiledValidator.new('resources/schematron/c32_v2.5_compiled.xslt')
      @c32_schematron_validator
    end

    def self.c32_schema_validator
      @c32_schema_validator ||= XMLSchemaValidator.new('resources/xml_schema/cdar2c32/infrastructure/cda/C32_CDA.xsd')
      @c32_schema_validator
    end

    def self.ccr_schema_validator
      # because of licensing issues with ASTM and the CCR schema, the user may or may not have purchased
      # and downloaded the CCR schema .xsd, and integrated it with the popHealth importer user
      # interface.  Therefore, if the schema file is not present, return nil... otherwise...
      # create a XMLSchemaValidator object for the CCR, and return it
      @ccr_schema_validator ||= XMLSchemaValidator.new('resources/xml_schema/ccr/infrastructure/ccr.xsd')
      @ccr_schema_validator
      
      #@ccr_schema_validator = nil
      #ccr_schema_file = File.new("resources/xml_schema/ccr/infrastructure/ccr.xsd")
      #if ccr_schema_file.exists?
      #  puts "the ccr schema file exists..."
      #  @ccr_schema_validator ||= XMLSchemaValidator.new(ccr_schema_file.path)
      #else
      #  puts "the ccr schema file does not exist..."
      #end
      #@ccr_schema_validator
    end

  end

end