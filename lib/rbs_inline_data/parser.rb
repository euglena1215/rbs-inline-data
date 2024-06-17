# frozen_string_literal: true

require "prism"

module RbsInlineData
  class Parser < Prism::Visitor
    # @rbs skip
    TypedDefinition = Data.define(
      :class_name, #:: String
      :fields #:: Array[RbsInlineData::Parser::TypedField]
    )
    # @rbs skip
    TypedField = Data.define(
      :field_name, #:: String
      :type #:: String
    )
    # @rbs skip
    Comments = Data.define(
      :comment_lines #:: Hash[Integer, String]
    )
    class Comments
      MARKER = "#::"

      #:: (Array[Prism::Comment]) -> RbsInlineData::Parser::Comments
      def self.from_prism_comments(comments)
        # @type var comment_lines: Hash[Integer, String]
        comment_lines = {}
        comments.each do |comment|
          sliced = comment.slice
          next unless sliced.start_with?(MARKER)

          comment_lines[comment.location.start_line] = sliced.sub(MARKER, "").strip
        end

        new(comment_lines:)
      end
    end

    # @rbs @definitions: Array[RbsInlineData::Parser::TypedDefinition]
    # @rbs @surronding_class_or_module: Array[Symbol]
    # @rbs @comments: RbsInlineData::Parser::Comments

    # rubocop:disable Lint/MissingSuper
    #:: (Array[RbsInlineData::Parser::TypedDefinition], RbsInlineData::Parser::Comments) -> void
    def initialize(definitions, comments)
      @definitions = definitions
      @comments = comments
      @surronding_class_or_module = []
    end
    # rubocop:enable Lint/MissingSuper

    #:: (Prism::ParseResult) -> Array[RbsInlineData::Parser::TypedDefinition]
    def self.parse(result)
      # @type var definitions: Array[RbsInlineData::Parser::TypedDefinition]
      definitions = []
      comments = Comments.from_prism_comments(result.comments)
      instance = new(definitions, comments)
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
      arguments_node = node.value.arguments
      if arguments_node
        typed_fields = arguments_node.arguments.map do |sym_node|
          return nil unless sym_node.is_a?(Prism::SymbolNode)

          TypedField.new(
            field_name: sym_node.unescaped,
            type: type_of(sym_node)
          )
        end.compact
      end

      TypedDefinition.new(
        class_name: "#{@surronding_class_or_module.join("::")}::#{node.name}",
        fields: typed_fields || []
      )
    end

    #:: (Prism::SymbolNode) -> String
    def type_of(node)
      @comments.comment_lines[node.location.start_line] || "untyped"
    end
  end
end
