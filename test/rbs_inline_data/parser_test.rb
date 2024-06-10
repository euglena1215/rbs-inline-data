require "test_helper"
require "rbs_inline_data/parser"

module RbsInlineData
  class ParserTest < Minitest::Test
    def parse_ruby(src)
      Prism.parse(src)
    end

    def test_simple
      definitions = Parser.parse(parse_ruby(<<~RUBY))
        class Foo
          Bar = Data.define(
            :value, #:: String
          )
          Bar2=Data.define(
            :value, #:: Integer
          )
        end
      RUBY

      assert_equal definitions[0], Parser::TypedDefinition.new(
        class_name: "Foo::Bar",
        fields: [
          Parser::TypedField.new(field_name: "value", type: "String"),
        ])
      assert_equal definitions[1], Parser::TypedDefinition.new(
        class_name: "Foo::Bar2",
        fields: [
          Parser::TypedField.new(field_name: "value", type: "Integer"),
        ])
    end

    def test_multiple_definition
      definitions = Parser.parse(parse_ruby(<<~RUBY))
        class Foo
          Bar = Data.define(
            :string_value, #:: String
          )
          Bar2 = Data.define(
            :string_value, #:: String
          )
        end
      RUBY

      assert_equal definitions[0], Parser::TypedDefinition.new(
        class_name: "Foo::Bar",
        fields: [
          Parser::TypedField.new(field_name: "string_value", type: "String"),
        ])
      assert_equal definitions[1], Parser::TypedDefinition.new(
        class_name: "Foo::Bar2",
        fields: [
          Parser::TypedField.new(field_name: "string_value", type: "String"),
        ])
    end

    def test_untyped
      definitions = Parser.parse(parse_ruby(<<~RUBY))
        class Foo
          Bar = Data.define(
            :value #:: untyped
          )
          Bar2 = Data.define(
            :value
          )
          Bar3 = Data.define(:value)
        end
      RUBY

      assert_equal definitions[0], Parser::TypedDefinition.new(
        class_name: "Foo::Bar",
        fields: [
          Parser::TypedField.new(field_name: "value", type: "untyped"),
        ])
      assert_equal definitions[1], Parser::TypedDefinition.new(
        class_name: "Foo::Bar2",
        fields: [
          Parser::TypedField.new(field_name: "value", type: "untyped"),
        ])
      assert_equal definitions[2], Parser::TypedDefinition.new(
        class_name: "Foo::Bar3",
        fields: [
          Parser::TypedField.new(field_name: "value", type: "untyped"),
        ])
    end

    def test_nested_type
      definitions = Parser.parse(parse_ruby(<<~RUBY))
        class A
          class B
            class C; end
            D = Data.define(
              :x, #:: A::B::C
              :y #:: Array[A::B::C]
            )
          end
        end
      RUBY

      assert_equal definitions[0], Parser::TypedDefinition.new(
        class_name: "A::B::D",
        fields: [
          Parser::TypedField.new(field_name: "x", type: "A::B::C"),
          Parser::TypedField.new(field_name: "y", type: "Array[A::B::C]"),
        ])
    end
  end
end
