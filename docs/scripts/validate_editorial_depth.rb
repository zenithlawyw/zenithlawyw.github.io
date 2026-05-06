#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

FORBIDDEN_HEADERS = [
  'Source Inventory and Evidence Grading',
  'Verified finding',
  'Inferred synthesis',
  'Unverified detail'
].freeze

META_PROCESS_PATTERNS = [
  /\bsynthesi[sz](e|ed|ing)\b/i,
  /\bthis (article|post) (is|was) (a )?synthesis\b/i,
  /\bwriting process\b/i,
  /\bmeta-process\b/i
].freeze

def read_file(path)
  raise "File not found: #{path}" unless File.file?(path)

  File.read(path)
end

def section_blocks(content)
  lines = content.lines
  sections = []
  current = nil

  lines.each_with_index do |line, idx|
    if line.start_with?('## ')
      sections << current if current
      current = {
        header: line.sub(/^##\s+/, '').strip,
        start_line: idx + 1,
        body: []
      }
    elsif current
      current[:body] << line
    end
  end

  sections << current if current
  sections
end

def markdown_word_count(text)
  text
    .gsub(/\{%-?.*?-?%\}/m, ' ')
    .gsub(/\[([^\]]+)\]\([^\)]+\)/, '\\1')
    .gsub(/`[^`]+`/, ' ')
    .scan(/[A-Za-z0-9\-']+/)
    .length
end

def short_major_sections(sections)
  sections.filter do |section|
    next false if section[:header].downcase.include?('frequently asked questions')
    next false if section[:header].downcase.include?('technical appendix')

    markdown_word_count(section[:body].join) < 80
  end
end

def forbidden_header_hits(sections)
  sections.filter do |section|
    FORBIDDEN_HEADERS.any? { |h| section[:header].casecmp?(h) }
  end
end

def meta_process_hits(content)
  lines = content.lines
  hits = []

  lines.each_with_index do |line, idx|
    next if line.strip.start_with?('>')

    META_PROCESS_PATTERNS.each do |pattern|
      if line.match?(pattern)
        hits << { line: idx + 1, text: line.strip }
        break
      end
    end
  end

  hits
end

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby docs/scripts/validate_editorial_depth.rb <post-file.md>'
end.parse!

path = ARGV[0]
abort('Error: missing post file path argument') unless path

content = read_file(path)
sections = section_blocks(content)

issues = []

bad_headers = forbidden_header_hits(sections)
unless bad_headers.empty?
  issues << 'Forbidden process-style headers detected:'
  bad_headers.each do |h|
    issues << "  - line #{h[:start_line]}: #{h[:header]}"
  end
end

short_sections = short_major_sections(sections)
unless short_sections.empty?
  issues << 'Major sections that appear too brief (<80 words):'
  short_sections.each do |s|
    issues << "  - line #{s[:start_line]}: #{s[:header]}"
  end
end

meta_hits = meta_process_hits(content)
unless meta_hits.empty?
  issues << 'Meta-process wording detected in reader-facing prose:'
  meta_hits.each do |hit|
    issues << "  - line #{hit[:line]}: #{hit[:text]}"
  end
end

if issues.empty?
  puts "Editorial depth validation passed: #{path}"
  exit 0
end

puts "Editorial depth validation failed: #{path}"
puts
issues.each { |i| puts i }
exit 1
