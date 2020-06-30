require 'cfhlspec/cftest'

module Cfhlspec::Matchers::Compiles
    def compiler(cftest)
        begin
            cftest.compile_template
        rescue => e
            @error = e.message
            return false
        end
        return true
    end
end

RSpec::Matchers.define :compile do
    include Cfhlspec::Matchers::Compiles
    
    match do |cftest|
        compiler(cftest)
    end

    failure_message do
        @error
    end
end