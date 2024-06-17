# frozen_string_literal: true

require "optparse"

require "rbs_inline_data/parser"
require "rbs_inline_data/writer"

module RbsInlineData
  # Process executed when running the rbs-inline-data command.
  class CLI
    #:: (Array[String]) -> void
    def run(args)
      # @type var output_path: Pathname?
      output_path = nil

      OptionParser.new do |opts|
        opts.on("--output", "Output to stdout instead of writing to files") do
          output_path = Pathname("sig/generated/data")
        end
      end.parse!(args)

      targets = Pathname.glob(args[0]).flat_map do |path|
        if path.directory?
          Pathname.glob(path.join("**/*.rb").to_s)
        else
          path
        end
      end

      targets.sort!
      targets.uniq!

      targets.each do |target|
        result = Prism.parse_file(target.to_s)
        definitions = Parser.parse(result)
        Writer.write(definitions, output_path ? (output_path + target).sub_ext(".rbs") : nil)
      end
    end
  end
end
