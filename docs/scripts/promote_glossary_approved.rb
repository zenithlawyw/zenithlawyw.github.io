#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'time'

ROOT = File.expand_path('..', __dir__)
AUTO_FILE = File.join(ROOT, '_data', 'glossary_auto.yml')
TERMS_FILE = File.join(ROOT, '_data', 'glossary_terms.yml')

def load_yaml(path, default)
  return default unless File.exist?(path)

  data = YAML.safe_load(File.read(path), aliases: true)
  data.nil? ? default : data
rescue StandardError
  default
end

def normalize_term(term)
  term.to_s.gsub(/\s+/, ' ').strip.downcase
end

def normalize_entry(entry)
  {
    'term' => entry['term'].to_s.strip,
    'definition' => entry['definition'].to_s.strip.empty? ? entry['suggested_definition'].to_s.strip : entry['definition'].to_s.strip,
    'source' => entry['source'].is_a?(Hash) ? entry['source'] : nil,
    'related_posts' => entry['related_posts'].is_a?(Array) ? entry['related_posts'] : nil
  }.delete_if { |_k, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
end

auto = load_yaml(AUTO_FILE, {})
terms = load_yaml(TERMS_FILE, [])
terms = [] unless terms.is_a?(Array)

approved = Array(auto['candidates']).select do |entry|
  entry.is_a?(Hash) && entry['status'].to_s.strip.downcase == 'approved' && !entry['term'].to_s.strip.empty?
end

existing_by_key = {}
result_terms = []
duplicate_existing = 0

terms.each do |entry|
  next unless entry.is_a?(Hash)

  key = normalize_term(entry['term'])
  next if key.empty?

  if existing_by_key.key?(key)
    duplicate_existing += 1
    next
  end

  existing_by_key[key] = true
  result_terms << entry
end

promoted = 0
skipped_existing = 0

approved.each do |entry|
  key = normalize_term(entry['term'])
  next if key.empty?

  if existing_by_key.key?(key)
    skipped_existing += 1
    next
  end

  normalized = normalize_entry(entry)
  next if normalized['term'].to_s.empty? || normalized['definition'].to_s.empty?

  result_terms << normalized
  existing_by_key[key] = true
  promoted += 1
end

result_terms.sort_by! { |entry| entry['term'].to_s.downcase }

if result_terms != terms
  File.write(TERMS_FILE, YAML.dump(result_terms))
end

puts "Glossary promotion summary"
puts "- Approved candidates found: #{approved.length}"
puts "- Promoted into glossary_terms.yml: #{promoted}"
puts "- Skipped (already exists): #{skipped_existing}"
puts "- Removed duplicate existing entries: #{duplicate_existing}"
puts "- Updated at: #{Time.now.utc.iso8601}"
