module HQMF
  # Simple class to issue monotonically increasing integer identifiers
  class Counter
    def initialize
      @count = 0
    end

    def next
      @count+=1
    end
  end
end    
