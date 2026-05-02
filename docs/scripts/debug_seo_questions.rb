#!/usr/bin/env ruby
# frozen_string_literal: true
# Debug script to understand why questions aren't being extracted

require 'yaml'

QUESTION_PREFIX = /^(who|what|why|how|when|where|can|should|is|are|do|does|did|will)\b/i
GENERIC_QUESTION_PATTERNS = [
  /\Awhy\s+this\s+matters\??\z/i,
  /\Aoverview\??\z/i,
  /\Aintroduction\??\z/i
].freeze

def split_front_matter(raw)
  return [{}, raw] unless raw.start_with?("---\n")
  parts = raw.split(/^---\s*$\n?/, 3)
  return [{}, raw] if parts.length < 3
  front = YAML.safe_load(parts[1], permitted_classes: [Time, Date], aliases: true) || {}
  [front, parts[2] || '']
rescue StandardError
  [{}, raw]
end

def clean_sentence(text)
  value = text.to_s.dup
  value.gsub!(/\{%\s*include\s+references\/cite\.html[^%]*%\}/m, ' ')
  value.gsub!(/\{%.*?%\}/m, ' ')
  value.gsub!(/\{\{.*?\}\}/m, ' ')
  value.gsub!(/\s+/, ' ')
  value.gsub!(/\s+([,.;:!?])/, '\1')
  value.strip
end

def normalize_question(text)
  value = clean_sentence(text)
  value = value.sub(/\A#+\s*/, '').strip
  value = value.sub(/\{:.+\}\s*\z/, '').strip
  return '' if value.empty?
  if value.match?(QUESTION_PREFIX) && !value.end_with?('?')
    value = "#{value}?"
  end
  value
end

def quality_question?(question)
  return false if question.empty?
  return false if question.length < 10 || question.length > 180
  return false unless question.end_with?('?') || question.match?(QUESTION_PREFIX)
  return false if GENERIC_QUESTION_PATTERNS.any? { |pattern| question.match?(pattern) }
  true
end

def quality_answer?(answer)
  return false if answer.empty?
  return false if answer.length < 24
  return false if answer.match?(/\Asee\s+the\s+section\b/i)
  true
end

# Read the post
post_path = File.join(File.dirname(__dir__), '_posts', '2026-04-23-support-vector-machine-practical-guide-kernels-margin-tuning.md')
raw = File.read(post_path)

puts "Raw length: #{raw.length}"
puts "Starts with ---: #{raw.start_with?("---\n")}"

front, body = split_front_matter(raw)
puts "Body length: #{body.length}"
puts "Front matter title: #{front['title']}"
puts ""

# Test heading extraction
lines = body.lines
puts "Body line count: #{lines.length}"

# Find headings
question_headings = 0
total_headings = 0
lines.each_with_index do |line, index|
  next unless line =~ /^#{2,6}\s+(.+)$/
  total_headings += 1
  heading_raw = $1.to_s
  heading = normalize_question(heading_raw)
  if quality_question?(heading)
    question_headings += 1
    
    # Get answer
    answer_lines = []
    i = index + 1
    while i < lines.length
      current = lines[i]
      break if current =~ /^#{1,6}\s+/ || current.strip.start_with?('---')
      stripped = current.strip
      answer_lines << stripped unless stripped.empty?
      break if answer_lines.length >= 3
      i += 1
    end
    
    answer = clean_sentence(answer_lines.join(' '))
    if quality_answer?(answer)
      puts "PASS Q: #{heading}"
      puts "     A: #{answer[0..100]}"
    else
      puts "FAIL Q: #{heading}"
      puts "     A (#{answer.length} chars): '#{answer[0..100]}'"
    end
  end
end
puts ""
puts "Total headings found: #{total_headings}"
puts "Question headings: #{question_headings}"
