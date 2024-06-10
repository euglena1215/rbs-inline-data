# frozen_string_literal: true

module RbsInlineData
  class Writer
    #:: (Array[RbsInlineData::Parser::TypedDefinition], Pathname?) -> void
    def self.write(definitions, output_path)
      new(definitions).write(output_path)
    end

    # @rbs @definitions: Array[RbsInlineData::Parser::TypedDefinition]

    #:: (Array[RbsInlineData::Parser::TypedDefinition]) -> void
    def initialize(definitions)
      @definitions = definitions
    end

    #:: (Pathname?) -> void
    def write(output_path)
      return if @definitions.empty?

      if output_path
        output_path.parent.mkpath unless output_path.parent.directory?
        output_path.write(build_rbs(@definitions))
      else
        puts build_rbs(@definitions)
      end
    end

    private

    #:: (Array[RbsInlineData::Parser::TypedDefinition]) -> String
    def build_rbs(definitions)
      rbs_text = ""
      definitions.each do |definition|
        source = <<~RBS
          class #{definition.class_name}
            extend Data::_DataClass
            #{definition.fields.map { |field| "attr_reader #{field.field_name}: #{field.type}" }.join("\n  ")}
            def self.new: (*untyped) -> ::#{definition.class_name}
                        | (**untyped) -> ::#{definition.class_name}
                        | ...
          end
        RBS

        rbs_text += "#{source}\n"
      end
      rbs_text
    end
  end
end
