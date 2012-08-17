require_relative '../../../test_helper'

class HQMFV1V2RoundtripTest < Test::Unit::TestCase

  def setup
    # Parse the sample file and convert to the model
    hqmf_xml = File.open('test/fixtures/1.0/0033/0033.xml').read
    @v1_model = HQMF::Parser.parse(hqmf_xml, '1.0')
    # serialize the model using the HQMF2 generator back to XML and then
    # reparse it
    hqmf_xml = HQMF2::Generator::ModelProcessor.to_hqmf(@v1_model)
    @v2_model = HQMF::Parser.parse(hqmf_xml, '2.0')
  end

  def test_roundtrip
    v1_json = JSON.parse(@v1_model.to_json.to_json)
    v2_json = JSON.parse(@v2_model.to_json.to_json)

    # remove any source_data_criteria or specific_occurrence_const from v1 tree since
    # we don't support these in v2_model
    v1_json['data_criteria'].each_pair do |key, criteria|
      criteria['source_data_criteria'] = key
      criteria['specific_occurrence_const'] = nil
      criteria['specific_occurrence'] = nil
    end
    v1_json['source_data_criteria'] = nil
    v1_json['measure_period']['width'] = nil

    diff = v1_json.diff_hash(v2_json, true, true)

    outfile = File.join(".","tmp","v1_v2_diffs.json")
    File.open(outfile, 'w') {|f| f.write(JSON.pretty_generate(JSON.parse(diff.to_json))) }
    outfile = File.join(".","tmp","v1.json")
    File.open(outfile, 'w') {|f| f.write(JSON.pretty_generate(v1_json)) }
    outfile = File.join(".","tmp","v2.json")
    File.open(outfile, 'w') {|f| f.write(JSON.pretty_generate(v2_json)) }

  end
  
end
