module HQMF
  
  module Converter
  
    class SimpleDataCriteria < HQMF::DataCriteria

      attr_accessor :precondition_id

      def self.from_data_criteria(data_criteria)
        description = get_description(data_criteria)
        
        HQMF::Converter::SimpleDataCriteria.new(data_criteria.id, data_criteria.title, data_criteria.display_name, description, data_criteria.code_list_id, 
          data_criteria.children_criteria, data_criteria.derivation_operator, data_criteria.definition,data_criteria.status, data_criteria.value, data_criteria.field_values, 
          data_criteria.effective_time, data_criteria.inline_code_list,data_criteria.negation,data_criteria.negation_code_list_id,data_criteria.temporal_references, data_criteria.subset_operators, data_criteria.specific_occurrence,data_criteria.specific_occurrence_const)
      end

      def assign_precondition(precondtion_id)
        return if (@precondtion_id == precondtion_id)
        raise "Cannot assign a second precondition to a data criteria" if @precondition_id
        @precondition_id = precondtion_id
        @id = "#{@id}_precondition_#{precondtion_id}"
      end
      
      def self.get_description(data_criteria)
        description = data_criteria.description
        status = ", #{data_criteria.status.titleize}" if data_criteria.status
        description = "#{data_criteria.definition.titleize}#{status}: #{data_criteria.description}" if (data_criteria.description.downcase.match /#{data_criteria.definition.titleize.downcase}/).nil? and (data_criteria.description.downcase.match /#{data_criteria.status}/).nil?
        description
      end
      
    end
  end
  
  
end