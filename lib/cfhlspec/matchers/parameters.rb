require 'cfhlspec/hash'

module Cfhlspec::Matchers::Parameters

    def validate_parameter(template:, param:)
        unless template.Parameters.respond_to? param
            @error = "expected parameter #{param} to exist in template but could not be found"
            return false
        end
        return true
    end

    def validate_parameter_with_properties(template:, param:, properties: {})
        properties.compact.each do |key, value|
            next if value.nil?

            unless validate_property(template: template, param: param, key: key, value: value)
                @error = "expected parameter #{param} to exist with properties #{properties}, got #{template.Parameters[param].to_h}"
                return false
            end
        end
        return true
    end

    def validate_property(template:, param:, key:, value:)
        template.Parameters[param][key] == value
    end

end

RSpec::Matchers.define :have_parameter do |parameter|
    include Cfhlspec::Matchers::Parameters

    chain :with_type do |type|
        @type = type
    end

    chain :with_default_value do |default_value|
        @default_value = default_value
    end

    chain :with_allowed_values do |allowed_values|
       @allowed_values = allowed_values
    end

    match do |template|
        validate_parameter(template: template, param: parameter) &&
        validate_parameter_with_properties(
            template: template, 
            param: parameter, 
            properties: {
                Type: @type,
                Default: @default_value,
                AllowedValues: @allowed_values
            }
        )
    end

    failure_message do
        @error
    end
end