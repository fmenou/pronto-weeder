# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'pronto/weeder/version'

Gem::Specification.new do |s|
  s.name     = 'pronto-weeder'
  s.version  = Pronto::Weeder::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors  = ['Frederic Menou']
  s.email    = 'frederic.menou@fretlink.com'
  s.homepage = 'https://github.com/fretlink/pronto-weeder'
  s.summary  = <<-EOF
    Pronto runner for Weeder, pluggable dead code analysis utility for Haskell
  EOF

  s.licenses              = ['MIT']
  s.required_ruby_version = '>= 2.3.0'

  s.files            = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(lib/|(LICENSE|README.md)$)}) }
  s.extra_rdoc_files = ['LICENSE', 'README.md']
  s.require_paths    = ['lib']
  s.requirements << 'weeder (in PATH)'

  s.add_dependency('pronto', '~> 0.10.0')
  s.add_development_dependency('byebug', '>= 9')
  s.add_development_dependency('rake', '>= 11.0', '< 13')
  s.add_development_dependency('rspec', '~> 3.4')
end
