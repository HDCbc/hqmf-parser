require_relative '../../../test_helper'
module HQMF1
  
  # 0033 has patient characteristic gender, so it is used to verify the backfilling of the gender as part of the conversion

  class NQF0033Test  < Test::Unit::TestCase
    def setup
      path = File.expand_path("../../../../fixtures/1.0/0033/0033.xml", __FILE__)
      @hqmf_contents = File.open(path).read
      
      @codes = {"2.16.840.1.113883.3.560.100.2" => {"HL7"=>["F"]},
                "2.16.840.1.113883.3.560.100.4" => {'LOINC'=>['21112-8']}}
      
    end
  
    def test_patient_criteria_backfill
      hqmf = HQMF::Parser.parse(@hqmf_contents, HQMF::Parser::HQMF_VERSION_1,@codes)
      
      gender_female = hqmf.data_criteria(hqmf.all_data_criteria.map(&:id).grep(/PatientCharacteristicGenderAdministrativeGenderFemale/).first)
      gender_female.value.code.must_equal "F"
      gender_female.value.system.must_equal "Gender"
      gender_female.value.type.must_equal "CD"
    end
      

    
  end
end
