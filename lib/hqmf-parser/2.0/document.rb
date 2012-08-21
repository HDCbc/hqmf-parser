module HQMF2
  # Class representing an HQMF document
  class Document

    include HQMF2::Utilities
    NAMESPACES = {'cda' => 'urn:hl7-org:v3', 'xsi' => 'http://www.w3.org/2001/XMLSchema-instance'}

    attr_reader :measure_period, :id, :populations, :attributes
  
    # Create a new HQMF2::Document instance by parsing at file at the supplied path
    # @param [String] path the path to the HQMF document
    def initialize(hqmf_contents)
      @doc = @entry = Document.parse(hqmf_contents)
      @id = attr_val('cda:QualityMeasureDocument/cda:id/@extension')
      measure_period_def = @doc.at_xpath('cda:QualityMeasureDocument/cda:controlVariable/cda:measurePeriod/cda:value', NAMESPACES)
      if measure_period_def
        @measure_period = EffectiveTime.new(measure_period_def)
      end
      
      # Extract measure attributes
      @attributes = @doc.xpath('/cda:QualityMeasureDocument/cda:subjectOf/cda:measureAttribute', NAMESPACES).collect do |attribute|
        id = attribute.at_xpath('./cda:id/@extension', NAMESPACES).try(:value)
        code = attribute.at_xpath('./cda:code/@code', NAMESPACES).try(:value)
        name = attribute.at_xpath('./cda:code/cda:displayName/@value', NAMESPACES).try(:value)
        value = attribute.at_xpath('./cda:value/@value', NAMESPACES).try(:value)
        HQMF::Attribute.new(id, code, value, nil, name)
      end
      
      # Extract the data criteria
      @data_criteria = @doc.xpath('cda:QualityMeasureDocument/cda:component/cda:dataCriteriaSection/cda:entry', NAMESPACES).collect do |entry|
        DataCriteria.new(entry)
      end
      
      # Extract the population criteria and population collections
      @populations = []
      @population_criteria = []
      @doc.xpath('cda:QualityMeasureDocument/cda:component/cda:populationCriteriaSection', NAMESPACES).each_with_index do |population_def, population_index|
        population = {}
        {
          'IPP' => 'patientPopulationCriteria',
          'DENOM' => 'denominatorCriteria',
          'NUMER' => 'numeratorCriteria',
          'DENEXCEP' => 'denominatorExceptionCriteria',
          'EXCL' => 'denominatorExclusionCriteria'
        }.each_pair do |criteria_id, criteria_element_name|
          criteria_def = population_def.at_xpath("cda:component[cda:#{criteria_element_name}]", NAMESPACES)
          if criteria_def
            criteria = PopulationCriteria.new(criteria_def, self)
            @population_criteria << criteria
            population[criteria_id] = criteria.id
          end
        end
        id_def = population_def.at_xpath('cda:id/@extension', NAMESPACES)
        population['id'] = id_def ? id_def.value : "Population#{population_index}"
        title_def = population_def.at_xpath('cda:title/@value', NAMESPACES)
        population['title'] = title_def ? title_def.value : "Population #{population_index}"
        @populations << population
      end
    end
    
    # Get the title of the measure
    # @return [String] the title
    def title
      @doc.at_xpath('cda:QualityMeasureDocument/cda:title/@value', NAMESPACES).inner_text
    end
    
    # Get the description of the measure
    # @return [String] the description
    def description
      description = @doc.at_xpath('cda:QualityMeasureDocument/cda:text/@value', NAMESPACES)
      description==nil ? '' : description.inner_text
    end
  
    # Get all the population criteria defined by the measure
    # @return [Array] an array of HQMF2::PopulationCriteria
    def all_population_criteria
      @population_criteria
    end
    
    # Get a specific population criteria by id.
    # @param [String] id the population identifier
    # @return [HQMF2::PopulationCriteria] the matching criteria, raises an Exception if not found
    def population_criteria(id)
      find(@population_criteria, :id, id)
    end
    
    # Get all the data criteria defined by the measure
    # @return [Array] an array of HQMF2::DataCriteria describing the data elements used by the measure
    def all_data_criteria
      @data_criteria
    end
    
    # Get a specific data criteria by id.
    # @param [String] id the data criteria identifier
    # @return [HQMF2::DataCriteria] the matching data criteria, raises an Exception if not found
    def data_criteria(id)
      find(@data_criteria, :id, id)
    end
    
    # Parse an XML document at the supplied path
    # @return [Nokogiri::XML::Document]
    def self.parse(hqmf_contents)
      doc = Nokogiri::XML(hqmf_contents)
      doc
    end
    
    def to_model
      dcs = all_data_criteria.collect {|dc| dc.to_model}
      pcs = all_population_criteria.collect {|pc| pc.to_model}
      source_data_criteria = []
      HQMF::Document.new(id, title, description, pcs, dcs, source_data_criteria, attributes, measure_period.to_model, populations)
    end
    
    private
    
    def find(collection, attribute, value)
      collection.find {|e| e.send(attribute)==value}
    end
  end
end