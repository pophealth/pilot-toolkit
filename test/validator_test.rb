require 'test/unit'
require 'lib/pilot_toolkit'

class ValidatorTest < Test::Unit::TestCase
  
  def test_schematron
    validator = Validation::ValidatorRegistry.c32_schematron_validator
    c32 = File.read('fixtures/demographics.xml')
    results = validator.validate(c32)
    assert results
    # Uncomment this line to print the error messages from schematron
    # puts results.map{|r| r[:error_message]}.join("\n")
    assert_equal 5, results.size
  end
  
  def test_xml_schema
    validator = Validation::ValidatorRegistry.c32_xml_schema_validator
    c32 = File.read('fixtures/demographics.xml')
    results = validator.validate(c32)
    assert results
    assert_equal 1, results.size
  end
end