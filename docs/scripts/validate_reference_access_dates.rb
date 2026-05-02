#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "yaml"

ROOT = File.expand_path("..", __dir__)
POSTS_DIR = File.join(ROOT, "_posts")
REFERENCES_FILE = File.join(ROOT, "_data", "references.yml")
GENERATED_REFERENCES_FILE = File.join(ROOT, "_data", "references_generated.yml")
generated_references = File.exist?(GENERATED_REFERENCES_FILE) ? (YAML.load_file(GENERATED_REFERENCES_FILE) || {}) : {}
violations = []

def load_references_data(data_key)
  key = (data_key || "references").to_s
  data_path = File.join(ROOT, "_data", "#{key}.yml")
  return {} unless File.exist?(data_path)

  YAML.load_file(data_path) || {}
rescue StandardError
  {}
end

def parse_frontmatter(file_path)
  text = File.read(file_path)
  return {} unless text.start_with?("---\n")

  parts = text.split(/^---\s*$\n?/)
  return {} if parts.length < 3

  YAML.safe_load(parts[1], permitted_classes: [Date, Time], aliases: true) || {}
rescue StandardError
  {}
end

def post_date_for(file_path, frontmatter)
  basename = File.basename(file_path)
  filename_date = basename[/^(\d{4}-\d{2}-\d{2})-/, 1]
  return Date.strptime(filename_date, "%Y-%m-%d") if filename_date

  raw_date = frontmatter["date"]
  return Date.parse(raw_date.to_s) if raw_date

  nil
end

def parse_accessed_date(ieee_text)
  return nil unless ieee_text

  match = ieee_text.match(/Accessed:\s*(\d{1,2}\s+[A-Za-z]+\s+\d{4})\.?/i)
  return nil unless match

  Date.strptime(match[1], "%d %B %Y")
rescue StandardError
  nil
end

def parse_accessed_date_from_record(ref_record)
  iso = ref_record["accessed_iso"]
  return Date.iso8601(iso) if iso

  label = ref_record["accessed_date"]
  return Date.strptime(label, "%d %B %Y") if label

  parse_accessed_date(ref_record["ieee"]) || parse_accessed_date(ref_record["harvard"])
rescue StandardError
  nil
end

Dir.glob(File.join(POSTS_DIR, "*.md")).sort.each do |post_path|
  frontmatter = parse_frontmatter(post_path)
  references_list = frontmatter["references"]
  next unless references_list.is_a?(Array) && !references_list.empty?

  selected_references = load_references_data(frontmatter["references_data"])

  publication_date = post_date_for(post_path, frontmatter)
  next unless publication_date

  references_list.each do |ref_key|
    ref_record = generated_references[ref_key] || selected_references[ref_key]
    next unless ref_record.is_a?(Hash)

    accessed_date = parse_accessed_date_from_record(ref_record)
    next unless accessed_date

    next unless accessed_date > publication_date

    violations << {
      post: File.basename(post_path),
      publication_date: publication_date,
      reference_key: ref_key,
      accessed_date: accessed_date
    }
  end
end

if violations.empty?
  puts "OK: reference access-date integrity check passed"
  exit 0
end

warn "ERROR: reference access-date integrity violations detected"
violations.each do |violation|
  warn "  - Post #{violation[:post]} (publication #{violation[:publication_date]}) cites #{violation[:reference_key]} with accessed #{violation[:accessed_date]}"
end
warn "Fix by adjusting reference Accessed dates or revising the post publication/revision metadata."
exit 1