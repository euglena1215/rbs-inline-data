module RbsInlineData
  class Writer
    #:: (Pathname, Array[RbsInlineData::Parser::TypedDefinition]) -> void
    def self.write(file, definitions)
      new(file, definitions).write
    end

    # @rbs @file: Pathname
    # @rbs @definitions: Array[RbsInlineData::Parser::TypedDefinition]

    #:: (Pathname, Array[RbsInlineData::Parser::TypedDefinition]) -> void
    def initialize(file, definitions)
      @file = file
      @definitions = definitions
    end

    # () -> void
    def write
      return if @definitions.empty?

      puts "file: #{@file}"
      rbs = ""
      @definitions.each do |definition|
        source = <<~RBS
          class #{definition.class_name}
            extend Data::_DataClass
            #{definition.fields.map { |field| "attr_reader #{field.field_name}: #{field.type}" }.join("\n  ")}
            def self.new: (*untyped) -> #{definition.class_name}
                        | (**untyped) -> #{definition.class_name}
                        | ...
          end
        RBS
        rbs += source + "\n"
      end

      puts rbs
    end
  end
end
