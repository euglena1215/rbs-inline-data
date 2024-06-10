require 'prism'

module RbsInlineData
  class Parser < Prism::Visitor
    # @rbs skip
    TypedDefinition = Data.define(
      :class_name, #:: String
      :fields, #:: Array[TypedField]
    )
    # @rbs skip
    TypedField = Data.define(
      :field_name, #:: String
      :type, #:: String
    )

    # @rbs @definitions: Array[RbsInlineData::Parser::TypedDefinition]
    # @rbs @surronding_class_or_module: Array[Symbol]

    #:: (Array[RbsInlineData::Parser::TypedDefinition]) -> void
    def initialize(definitions)
      @definitions = definitions
      @surronding_class_or_module = []
    end

    #:: (Prism::ParseResult) -> Array[RbsInlineData::Parser::TypedDefinition]
    def self.parse(result)
      # @type var definitions: Array[RbsInlineData::Parser::TypedDefinition]
      definitions = []
      instance = self.new(definitions)
      result.value.accept(instance)
      definitions
    end

    # @rbs override
    def visit_class_node(node)
      record_surrounding_class_or_module(node) { super }
    end

    # @rbs override
    def visit_module_node(node)
      record_surrounding_class_or_module(node) { super }
    end

    # @rbs override
    def visit_constant_write_node(node)
      if define_data?(node)
        definition = extract_definition(node)
        @definitions << definition if definition
      end

      super
    end

    private

    #:: (Prism::ClassNode | Prism::ModuleNode) { (Prism::ClassNode | Prism::ModuleNode) -> void } -> void
    def record_surrounding_class_or_module(node)
      @surronding_class_or_module.push(node.constant_path.name)
      yield(node)
    ensure
      @surronding_class_or_module.pop
    end

    #:: (Prism::ConstantWriteNode) -> bool
    def define_data?(node)
      node in {
        value: Prism::CallNode[
          receiver: (
            Prism::ConstantReadNode[name: :Data] |
            Prism::ConstantPathNode[parent: nil, name: :Data]
          ),
          name: :define,
        ]
      }
    end

    #:: (Prism::ConstantWriteNode) -> RbsInlineData::Parser::TypedDefinition?
    def extract_definition(node)
      source = node.slice
      _, class_name, field_text = source.match(/\A([a-zA-Z]+) = Data\.define\(([\n\s\w\W]+)\)\z/).to_a
      return nil if field_text.nil? || class_name.nil?

      class_name = @surronding_class_or_module.join("::") + "::" + class_name

      fields = field_text.split("\n").map(&:strip).map do |str|
        str.match(/:(\w+), #:: ([\w\[\]]+)/)&.to_a
      end.compact.map { |_, field_name, type| TypedField.new(field_name: field_name, type: type) }

      TypedDefinition.new(
        class_name: class_name,
        fields: fields,
      )
    end
  end
end
