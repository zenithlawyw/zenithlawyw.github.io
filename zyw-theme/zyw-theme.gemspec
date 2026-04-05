# frozen_string_literal: true
Gem::Specification.new do |spec|
  spec.name     = "zyw-theme"
  spec.version  = "0.1.0"
  spec.authors  = ["zenithlawyw"]
  spec.license  = "MIT"
  spec.summary  = "Zyw theme"
  spec.homepage = "https://github.com/zenithlawyw/zenithlawyw.github.io/zyw-theme"
  spec.license  = "MIT"

  spec.files = Dir[
    "_layouts/**/*", "_includes/**/*",
    "assets/**/*",
    "LICENSE", "README.md"
  ]

  spec.add_runtime_dependency "jekyll", ">= 3.10", "< 5.0"
  spec.add_runtime_dependency "jekyll-feed", "~> 0.17"
  spec.add_runtime_dependency "jekyll-seo-tag", "~> 2.8"
  spec.add_runtime_dependency "jekyll-sitemap", "~> 1.4"
  spec.add_runtime_dependency "jekyll-paginate", "~> 1.1"
  spec.add_runtime_dependency "jekyll-spaceship", "~> 0.10"
end