require 'yaml'
require 'json'
require "ostruct"
require 'fileutils'
require 'cfhlspec/hash'
require 'cfhighlander.factory'
require 'cfhighlander.compiler'
require 'cfhighlander.validator'

module Cfhlspec
    class Cftest

        attr_reader :template_name, 
            :validate, 
            :name, 
            :out_path, 
            :out_format, 
            :out_file, 
            :component

        def initialize(name:, validate: true, yaml: nil, template_name:, config: {})
            @config = !yaml.nil? ? YAML.load_file(yaml) : config
            @template_name = template_name
            @validate = validate
            @name = name
            @parameters = []
            @out_path = "#{Dir.pwd}/out/spec/#{@name}"
            @out_format = 'yaml'
            @out_file = "#{@template_name}.compiled.#{@out_format}"
            ENV['CFHIGHLANDER_WORKDIR'] = Dir.pwd
        end

        def load_component()
            FileUtils.rm_rf @out_path
            component_loader = Cfhighlander::Factory::ComponentFactory.new
            @component = component_loader.loadComponentFromTemplate(@template_name)
            @component.config = load_default_config.deep_merge(@config)
            @component.load

            @parameters.each { |param| @component.highlander_dsl.parameters.ComponentParam(param[:name],param[:value]) }
        end

        def with_parameter(name:, value:)
            @parameters << {name: name, value: value}
        end

        def load_template()
            begin
                JSON.parse(YAML::load_file("#{@out_path}/#{@out_file}").to_json, object_class: OpenStruct)
            rescue => e
                raise StandardError.new "unable to load #{@out_path}/#{@out_file}, has it been compiled?"
            end
        end

        def compile_template
            component_compiler = Cfhighlander::Compiler::ComponentCompiler.new(@component)
            component_compiler.cfn_output_location = @out_path
            component_compiler.silent_mode = true
            component_compiler.compileCloudFormation
        end

        def validate_template
            component_validator = Cfhighlander::Cloudformation::Validator.new(@component)
            component_validator.validate(["#{@out_path}/#{@out_file}"], @out_format)
        end

        private

        def load_default_config
            begin
                YAML.load_file("#{@template_name}.config.yaml") || {}
            rescue Errno::ENOENT => e
                {}
            end
        end

    end
end
