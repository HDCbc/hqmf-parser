module HQMF2
  module Utilities
    
    include HQMF::JSON::Utilities
    
    # Utility function to handle optional attributes
    # @param xpath an XPath that identifies an XML attribute
    # @return the value of the attribute or nil if the attribute is missing
    def attr_val(xpath)
      attr = @entry.at_xpath(xpath, HQMF2::Document::NAMESPACES)
      if attr
        attr.value
      else
        nil
      end
    end
    
    def to_xml
      @entry.to_xml
    end
    
    # TODO: this needs to be removed
    def js_name
      if !id
        raise "No identifier for #{self}"
      end
      id.gsub(/\W/, '_')
    end
    
  end
end  