# frozen_string_literal: true

require 'spec_helper'

module Pronto
  module Weeder
    describe Runner do
      let(:weeder) { Weeder::Runner.new(patches) }
      let(:patches) { [] }

      describe '#run' do
        subject(:run) { weeder.run }

        context 'patches are nil' do
          let(:patches) { nil }

          it 'returns an empty array' do
            expect(run).to eql([])
          end
        end

        context 'no patches' do
          let(:patches) { [] }

          it 'returns an empty array' do
            expect(run).to eql([])
          end
        end

        context 'patches with a one and a four warnings' do
          include_context 'test repo'

          let(:patches) { repo.diff('master') }

          it 'returns correct number of errors' do
            expect(run.count).to eql(3)
          end

          it 'has correct first message' do
            expect(run.first.msg).to match("Unused LANGUAGE pragma")
          end

          context(
            'with files to lint config that never matches',
            config: { 'files_to_lint' => 'will never match' }
          ) do
            it 'returns zero errors' do
              expect(run.count).to eql(0)
            end
          end

          context(
            'with files to lint config that matches only .lhs',
            config: { 'files_to_lint' => '\.lhs$' }
          ) do
            it 'returns correct amount of errors' do
              expect(run.count).to eql(0)
            end
          end

          context(
            'with different weeder executable',
            config: { 'weeder_executable' => './custom_weeder.sh' }
          ) do
            it 'calls the custom weeder weeder_executable' do
              expect { run }.to raise_error(JSON::ParserError, /weeder called!/)
            end
          end
        end
      end

      describe '#files_to_lint' do
        subject(:files_to_lint) { weeder.files_to_lint }

        it 'matches .he by default' do
          expect(files_to_lint).to match('Types.hs')
        end
      end

      describe '#weeder_executable' do
        subject(:weeder_executable) { weeder.weeder_executable }

        it 'is `weeder` by default' do
          expect(weeder_executable).to eql('weeder')
        end

        context(
          'with different weeder executable config',
          config: { 'weeder_executable' => 'custom_weeder' }
        ) do
          it 'is correct' do
            weeder.read_config
            expect(weeder_executable).to eql('custom_weeder')
          end
        end
      end

      describe '#weeder_command_line' do
        subject(:weeder_command_line) { weeder.send(:weeder_command_line, path) }
        let(:path) { '/some/path.rb' }

        it 'adds json output flag' do
          expect(weeder_command_line).to include('--json')
        end

        it 'adds path' do
          expect(weeder_command_line).to include(path)
        end

        it 'starts with weeder executable' do
          expect(weeder_command_line).to start_with(weeder.weeder_executable)
        end

        context 'with path that should be escaped' do
          let(:path) { '/must be/$escaped' }

          it 'escapes the path correctly' do
            expect(weeder_command_line).to include('/must\\ be/\\$escaped')
          end

          it 'does not include unescaped path' do
            expect(weeder_command_line).not_to include(path)
          end
        end

        context(
          'with some command line options',
          config: { 'cmd_line_opts' => '--my command --line opts' }
        ) do
          it 'includes the custom command line options' do
            weeder.read_config
            expect(weeder_command_line).to include('--my command --line opts')
          end
        end
      end
    end
  end
end
