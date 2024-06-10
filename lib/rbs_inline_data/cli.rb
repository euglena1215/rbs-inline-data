# frozen_string_literal: true

require 'rbs_inline_data/parser'
require 'rbs_inline_data/writer'

module RbsInlineData
  class CLI
    #:: (Array[String]) -> void
    def run(args)
      unless args.size == 1
        raise ArgumentError, "Usage: rbs_inline_data <path/file>"
      end

      targets = Pathname.glob(args[0]).flat_map do |path|
        if path.directory?
          Pathname.glob(path.join("**/*.rb").to_s)
        else
          path
        end
      end

      targets.sort!
      targets.uniq!

      targets.each do |file|
        result = Prism.parse_file(file.to_s)
        definitions = Parser.parse(result)
        Writer.write(file, definitions)
      end
    end
  end
end
