module HQMF
  # Class for converting an HQMF 1.0 representation to an HQMF 2.0 representation
  class PopulationCriteriaConverter
    
    attr_reader :sub_measures
    
    def initialize(doc, data_criteria_converter)
      @doc = doc
      @data_criteria_converter = data_criteria_converter
      @population_criteria_by_id = {}
      @population_criteria_by_key = {}
      @population_reference = {}
      parse()
      build_sub_measures()
    end
    
    def population_criteria
      @population_criteria_by_key.values
    end
    
    private 
    
    def build_sub_measures()
      @sub_measures = []
      ipps = @population_criteria_by_id.select {|key, value| value.type == 'IPP'}
      denoms = @population_criteria_by_id.select {|key, value| value.type == 'DENOM'}
      nums = @population_criteria_by_id.select {|key, value| value.type == 'NUMER'}
      excls = @population_criteria_by_id.select {|key, value| value.type == 'DENEX'}
      denexcs = @population_criteria_by_id.select {|key, value| value.type == 'DENEXCEP'}
      
      if (ipps.size<=1 and denoms.size<=1 and nums.size<=1 and excls.size<=1 and denexcs.size<=1 )
        @sub_measures << {'IPP'=>'IPP', 'DENOM'=>'DENOM', 'NUMER'=>'NUMER', 'DENEXCEP'=>'DENEXCEP', 'DENEX'=>'DENEX'}
      else

        nums.each do |num_id, num|
          @sub_measures << {'NUMER' => num.id}
        end
        apply_to_submeasures(@sub_measures, 'DENOM', denoms.values)
        apply_to_submeasures(@sub_measures, 'IPP', ipps.values)
        apply_to_submeasures(@sub_measures, 'DENEX', excls.values)
        apply_to_submeasures(@sub_measures, 'DENEXCEP', denexcs.values)
        
        keep = []
        @sub_measures.each do |sub|
          
          value = sub
          ['IPP','DENOM','NUMER','DENEX','DENEXCEP'].each do |type|
            key = sub[type]
            if (key)
              reference_id = @population_reference[key]
              reference = @population_criteria_by_id[reference_id] if reference_id
              if (reference)
                criteria = @population_criteria_by_key[sub[reference.type]]
                value['stratification'] = criteria.stratification_id if criteria.stratification_id
                value = nil if (sub[reference.type] != reference.id and criteria.stratification_id.nil?)
              end
            end
          end
          keep << value if (value)
        end
        
        keep.each_with_index do |sub, i|
          sub['title'] = "Population #{i+1}"
          sub['id'] = "Population#{i+1}"
        end
        
        @sub_measures = keep
        
      end
    end
    
    def apply_to_submeasures(subs, type, values)
      new_subs = []
      subs.each do |sub|
        values.each do |value|
          if (sub[type] and sub[type] != value.id)
            tmp = {}
            ['IPP','DENOM','NUMER','DENEX','DENEXCEP'].each do |key|
              tmp[key] = sub[key] if sub[key]
            end
            sub = tmp
            new_subs << sub
          end
          sub[type] = value.id
        end
      end
      subs.concat(new_subs)
    end
    
    def find_sub_measures(type, value)
      found = []
      @sub_measures.each do |sub_measure|
        found << sub_measure if sub_measure[type] and sub_measure[type] == value.id
      end
      found
    end

    def parse()
      @doc[:logic].each do |key,criteria|
        @population_criteria_by_key[key] = convert(key.to_s, criteria)
      end
    end
   
    def convert(key, population_criteria)
      
      # @param [String] id
      # @param [Array#Precondition] preconditions 
      
      preconditions = HQMF::PreconditionConverter.parse_preconditions(population_criteria[:preconditions],@data_criteria_converter) 
      # TODO: NEED HQMF_ID to be correct for stratifications
      # hqmf_id = population_criteria[:hqmf_id] || population_criteria[:id]
      hqmf_id = population_criteria[:id]
      id = population_criteria[:id]
      type = population_criteria[:code]
      reference = population_criteria[:reference]
      title = population_criteria[:title]
      
      criteria = HQMF::Converter::SimplePopulationCriteria.new(key, hqmf_id, type, preconditions, title)
      # mark the 2.0 simple population criteria as a stratification... this allows us to create the cartesian product for this in the populations
      criteria.stratification_id = population_criteria[:stratification_id]
      
      @population_criteria_by_id[id] = criteria
      @population_reference[key] = reference
      
      criteria
     
    end
   
  end  
end
