# expect(template.Resources.SecurityGroupASG).to be_of_type('AWS::EC2::SecurityGroup')
# expect(template.Resources.SecurityGroupASG).to have_property(:VpcId).with_ref('VPCId')
# expect(template.Resources.SecurityGroupASG).to have_tags()
require 'json'
require 'cfhlspec/hash'

module Cfhlspec::Matchers::Resources

    def validate_resource(template:, resource:)
        unless template.Resources.dig(resource)
            @error = "expected #{resource} to exist in template but could not be found"
            return false
        end
        return true
    end

    def validate_type(resource:, type:)
        unless resource.Type == type
            @error = "expected to be of type #{type} but got #{resource.Type}"
            return false
        end
        return true
    end

    def validate_tags(resource:, keys:)
        resource_tag_keys = resource.dig(:Properties, :Tags).map {|tag| tag[:Key]}
        keys.each do |key|
            unless resource_tag_keys.include? key
                @error = "expected tags #{keys}, got #{resource_tag_keys}"
                return false
            end
        end
        return true
    end

    def validate_property(resource:, property:)
        unless resource.dig(:Properties, property)
            @error = "expected resource to have property #{property} but could not be found"
            return false
        end
        return true 
    end

    def validate_property_value(resource:, property:, value:)
        resource_property_value = resource.dig(:Properties, property).to_s
        unless resource_property_value == value
            @error = "expected resource to have property #{property} with value #{value} but got #{resource_property_value}"
            return false
        end
        return true
    end

end

RSpec::Matchers.define :have_resource do |resource|
    include Cfhlspec::Matchers::Resources

    match do |template|
        validate_resource(template: template, resource: resource)
    end

    failure_message do
        @error
    end
end

RSpec::Matchers.define :be_of_type do |type|
    include Cfhlspec::Matchers::Resources

    match do |resource|
        validate_type(resource: resource, type: type)
    end

    failure_message do
        @error
    end
end

RSpec::Matchers.define :have_property do |property|
    include Cfhlspec::Matchers::Resources

    chain :with_ref do |value|
        @value = { :Ref => value }
    end

    chain :with_value do |value|
        @value = value
    end

    match do |resource|
        validate_property(resource: resource, property: property) && 
        validate_property_value(resource: resource, property: property, value: @value)
    end

    failure_message do
        @error
    end
end

RSpec::Matchers.define :have_tags do |keys|
    include Cfhlspec::Matchers::Resources

    match do |resource|
        validate_tags(resource: resource, keys: keys)
    end

    failure_message do
        @error
    end
end