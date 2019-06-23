# frozen_string_literal: true

require 'pronto'
require 'shellwords'

module Pronto
  module Weeder
    class Runner < Pronto::Runner
      CONFIG_FILE = '.pronto_weeder.yml'.freeze
      CONFIG_KEYS = %w[weeder_executable files_to_lint cmd_line_opts].freeze

      attr_writer :weeder_executable, :cmd_line_opts

      def weeder_executable
        @weeder_executable || 'weeder'
      end

      def files_to_lint
        @files_to_lint || /(\.hs)$/
      end

      def cmd_line_opts
        @cmd_line_opts || ''
      end

      def files_to_lint=(regexp)
        @files_to_lint = regexp.is_a?(Regexp) && regexp || Regexp.new(regexp)
      end

      def config_options
        @config_options ||=
          begin
            config_file = File.join(repo_path, CONFIG_FILE)
            File.exist?(config_file) && YAML.load_file(config_file) || {}
          end
      end

      def read_config
        config_options.each do |key, val|
          next unless CONFIG_KEYS.include?(key.to_s)
          send("#{key}=", val)
        end
      end

      def run
        return [] if !@patches || @patches.count.zero?

        read_config

        @patches
          .select { |patch| patch.additions > 0 }
          .select { |patch| hs_file?(patch.new_file_full_path) }
          .map { |patch| inspect(patch) }
          .flatten.compact
      end

      private

      def repo_path
        @repo_path ||= @patches.first.repo.path
      end

      def inspect(patch)
        offences = run_weeder(patch)
        offences
          .map do |offence|
          patch
            .added_lines
            .select { |line| (offence['startLine']..offence['endLine']).include?(line.new_lineno) }
            .map { |line| new_message(offence, line) }
        end
      end

      def new_message(offence, line)
        path  = line.patch.delta.new_file[:path]
        level = weeder_severity_to_pronto_level(offence['severity']) || :warning

        text = <<~EOF
        #{offence['severity']} offence detected by Weeder. Hint is: `#{offence['hint']}`.

        Consider changing the code from
        ```
        #{offence['from']}
        ```
        to
        ```
        #{offence['to']}
        ```
      EOF

        Message.new(path, line, level, text, nil, self.class)
      end

      def weeder_severity_to_pronto_level(severity)
			  # TODO
        case severity
        when "Error"
          :error
        when "Warning"
          :warning
        when "Suggestion"
          :info
        end
      end

      def hs_file?(path)
        files_to_lint =~ path.to_s
      end

      def run_weeder(patch)
        Dir.chdir(repo_path) do
          JSON.parse `#{weeder_command_line(patch.new_file_full_path.to_s)}`
        end
      end

      def weeder_command_line(path)
        "#{weeder_executable} #{cmd_line_opts} #{Shellwords.escape(path)} --json"
      end
    end
  end
end
