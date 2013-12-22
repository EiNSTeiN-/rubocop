# encoding: utf-8

module Rubocop
  module Formatter
    # This formatter displays a YAML configuration file where all cops that
    # detected any offences are configured to not detect the offence.
    class DisabledConfigFormatter < BaseFormatter
      HEADING =
        ['# This configuration was generated by `rubocop --auto-gen-config`.',
         '# The point is for the user to remove these configuration records',
         '# one by one as the offences are removed from the code base.']
        .join("\n")

      @config_to_allow_offences = {}

      class << self
        attr_accessor :config_to_allow_offences
      end

      def file_finished(file, offences)
        @cops_with_offences ||= {}
        offences.each { |o| @cops_with_offences[o.cop_name] = true }
      end

      def finished(inspected_files)
        output.puts HEADING
        @cops_with_offences.keys.sort.each do |cop_name|
          output.puts
          output.puts "#{cop_name}:"
          cfg = self.class.config_to_allow_offences[cop_name]
          cfg ||= { 'Enabled' => false }
          cfg.each { |key, value| output.puts "  #{key}: #{value}" }
        end
        puts "Created #{output.path}."
        puts "Run rubocop with --config #{output.path}, or"
        puts "add inherit_from: #{output.path} in a .rubocop.yml file."
      end
    end
  end
end
