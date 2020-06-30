require 'aws-sdk-cloudformation'
require 'cfhlspec/cftest'

module Cfhlspec::Matchers::Validates
    def validator(cftest)
        begin
            cftest.validate_template
        rescue Aws::CloudFormation::Errors::ValidationError => e
            @error = e.message
            return false
        end
        return true
    end
end

RSpec::Matchers.define :validate do
    include Cfhlspec::Matchers::Validates
    
    match do |cftest|
        validator(cftest)
    end

    failure_message do
        @error
    end
end