# Cfhlspec

This library aims to build RSpec matchers for cfhighlander compile and vbalidate stages as well as matchers for cloudformation parameters, resources, conditions and outputs to improves cloudfomration testing

### Examples

### Compile and Validation

```ruby
require 'cfhlspec'

describe 'asg-v2 default template' do
    
    before(:all) do
       @cftest = Cfhlspec::Cftest.new(name: 'default', template_name: 'asg-v2', yaml: "tests/default.test.yaml")
       @cftest.load_component() 
    end

    it 'compiles' do
        expect(@cftest).to compile
    end

    it 'validates' do
        expect(@cftest).to validate
    end
end
```

### parameters

```ruby
let(:template) { @cftest.load_template()}

context 'parameters' do
    it 'EnvironmentName' do
        expect(template).to(have_parameter(:EnvironmentName)
            .with_type('String')
            .with_default_value('dev')
        )
    end

    it 'EnvironmentType' do
        expect(template).to(have_parameter(:EnvironmentType)
            .with_type('String')
            .with_default_value('development')
            .with_allowed_values(%w(development production))
        )
    end
end
```

### resources

```ruby
context 'resources' do
    context 'SecurityGroupASG' do
        it 'exists' do
            expect(template).to have_resource(:SecurityGroupAsg)
        end

        let(:securitygroup) { template.dig(:Resources, :SecurityGroupAsg) }

        it 'of type' do
            expect(securitygroup).to be_of_type('AWS::EC2::SecurityGroup')
        end

        it 'has property VpcId' do
            expect(securitygroup).to have_property('VpcId').with_ref('VPCId')
        end
        
        it 'has tags' do
            expect(securitygroup).to have_tags(['Name','Environment','EnvironmentType'])
        end
    end

    context 'InstanceProfile' do
        it 'exists' do
            expect(template).to have_resource(:InstanceProfile)
        end

        let(:instance_profile) { template.dig(:Resources, :InstanceProfile) }

        it 'of type' do
            expect(instance_profile).to be_of_type('AWS::IAM::InstanceProfile')
        end

        it 'has property VpcId' do
            expect(instance_profile).to have_property('Path').with_value('/')
        end
    end
end
```