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
      @ccr_schema_validator = nil
      # Because of licensing issues with ASTM and the CCR schema, the user may or may not have purchased
      # and downloaded the CCR schema .xsd, and integrated it with the popHealth importer user
      # interface.  Therefore, if the schema file is not present, return nil.
      if (File.exists?("resources/xml_schema/ccr/infrastructure/ccr.xsd"))
        puts "Found CCR Schema file"
        @ccr_schema_validator ||= XMLSchemaValidator.new('resources/xml_schema/ccr/infrastructure/ccr.xsd')
      end
      #puts " ccr_schema_validator is " + ccr_schema_validator
      @ccr_schema_validator
    end

  end

end