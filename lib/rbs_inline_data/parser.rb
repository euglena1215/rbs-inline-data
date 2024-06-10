require 'prism'
require 'pp'

module RbsInlineData
  class Parser
    class DefineDataVisitor < Prism::Visitor
      # @rbs @calls: Array[Prism::Node]

      def initialize(calls)
        @calls = calls
      end

      # @rbs override
      def visit_constant_write_node(node)
        @calls << node if define_data?(node)
        super
      end

      private

      #:: (Prism::Node) -> bool
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
    end

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

    # @rbs @file: Pathname

    #:: (Pathname) -> void
    def initialize(file)
      @file = file
    end

    #:: (Pathname) -> Array[RbsInlineData::Parser::TypedDefinition]
    def self.parse(file)
      new(file).parse
    end

    #:: () -> Array[RbsInlineData::Parser::TypedDefinition]
    def parse
      result = Prism.parse_file(@file.to_s)
      program_node = result.value

      # @type var nodes: Array[Prism::Node]
      nodes = []
      result.value.accept(DefineDataVisitor.new(nodes))

      nodes.map do |constant_write_node|
        extract_definition(constant_write_node.slice)
      end.compact
    end

    private

    #:: (String) -> RbsInlineData::Parser::TypedDefinition?
    def extract_definition(source)
      _, class_name, field_text = source.match(/\A([a-zA-Z]+) = Data\.define\(([\n\s\w\W]+)\)\z/).to_a
      return nil if field_text.nil?

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
