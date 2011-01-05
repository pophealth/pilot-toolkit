module Validation
  class ValidatorRegistry
    def self.c32_schematron_validator
      @c32_schematron_validator ||= SchematronValidator::CompiledValidator.new('resources/schematron/c32_v2.5_compiled.xslt')
      @c32_schematron_validator
    end
    
    def self.c32_xml_schema_validator
      @xml_schema_validator ||= XMLSchemaValidator.new('resources/xml_schema/cdar2c32/infrastructure/cda/C32_CDA.xsd')
      @xml_schema_validator
    end
  end
end