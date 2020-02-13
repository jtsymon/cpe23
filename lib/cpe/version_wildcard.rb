# frozen_string_literal: true

module Cpe
  class Version
    include Comparable
    attr_reader :parts

    def initialize(str)
      @parts = str.split('.')
      wildcard_index = @parts.index '*'
      if wildcard_index.nil?
        @parts << '*'
      elsif wildcard_index < @parts.size - 1
        raise 'Wildcard must be at the end of a version'
      end
    end

    def <=>(other)
      @parts.zip(other.parts).each do |a, b|
        break if a == '*' || b == '*'

        # Compare parts numerically if they are numeric
        if int?(a) && int?(b)
          a = a.to_i
          b = b.to_i
        end
        return -1 if a.to_i < b.to_i
        return 1 if a.to_i > b.to_i
      end
      0
    end

    private

    def int?(str)
      true if Integer(str)
    rescue StandardError
      false
    end
  end
end
