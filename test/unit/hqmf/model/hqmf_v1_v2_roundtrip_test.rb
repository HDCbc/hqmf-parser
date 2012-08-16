require_relative '../../../test_helper'

class HQMFV1V2RoundtripTest < Test::Unit::TestCase

  def setup
    # Parse the sample file and convert to the model
    hqmf_xml = File.open("test/fixtures/1.0/0033/0033.xml").read
    @v1_model = HQMF::Parser.parse(hqmf_xml, '1.0')
    # serialize the model using the HQMF2 generator back to XML and then
    # reparse it
    hqmf_xml = HQMF2::Generator::ModelProcessor.to_hqmf(@v1_model)
    @v2_model = HQMF::Parser.parse(hqmf_xml,"2.0")
  end

  def test_roundtrip
    diff = @v1_model.to_json.diff_hash(@v2_model.to_json)
  end
  
end
