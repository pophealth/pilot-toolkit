require 'test/unit'
require 'lib/pilot-toolkit'

class ValidatorTest < Test::Unit::TestCase
  
  def test_schematron
    validator = Validation::ValidatorRegistry.c32_schematron_validator
    c32 = File.read('fixtures/demographics.xml')
    results = validator.validate(c32)
    assert results
  end
  
  def test_xml_schema
    validator = Validation::ValidatorRegistry.c32_xml_schema_validator
    c32 = File.read('fixtures/demographics.xml')
    results = validator.validate(c32)
    assert results
  end
end