#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

ROOT = File.expand_path('..', __dir__)
SEO_AUTO_FILE = File.join(ROOT, '_data', 'seo_auto.yml')

unless File.exist?(SEO_AUTO_FILE)
  warn "Missing file: #{SEO_AUTO_FILE}"
  exit 1
end

data = YAML.safe_load(File.read(SEO_AUTO_FILE), aliases: true) || {}
posts = data['posts']

unless posts.is_a?(Hash)
  warn 'Invalid seo_auto.yml: posts section is missing or not a mapping'
  exit 1
end

empty_posts = posts.filter_map do |slug, record|
  questions = record.is_a?(Hash) ? record['questions'] : nil
  slug if !questions.is_a?(Array) || questions.empty?
end

if empty_posts.empty?
  puts "SEO FAQ validation passed: #{posts.length} posts have non-empty questions arrays"
  exit 0
end

warn 'SEO FAQ validation failed: posts with empty questions arrays detected:'
empty_posts.sort.each { |slug| warn "- #{slug}" }
exit 1