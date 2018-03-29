
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sequence_generator/version"

Gem::Specification.new do |spec|
  spec.name          = "sequence_generator"
  spec.version       = SequenceGenerator::VERSION
  spec.authors       = ["vimox-shah"]
  spec.email         = ["vimox@shipmnts.com"]

  spec.summary       = 'This gem is for generating sequence for different purposes'
  spec.description   = 'you can use this gem to generate different sequence'
  spec.homepage      = 'https://github.com/vimox-shah/sequence_generator'
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = TODO: Set to http://mygemserver.com
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  #mention versions of dependency
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "activesupport", ">= 3.0"
  spec.add_dependency "activerecord", ">= 3.0"
  Bundler.require(:default, :development)

end
