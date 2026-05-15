#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

ROOT = File.expand_path('..', __dir__)
SEO_AUTO_FILE = File.join(ROOT, '_data', 'seo_auto.yml')

MIN_QUESTION_LENGTH = 24
MIN_ANSWER_LENGTH = 55

GENERIC_QUESTION_PATTERNS = [
  /\Awhy\s+this\s+matters\??\z/i,
  /\Aoverview\??\z/i,
  /\Aintroduction\??\z/i,
  /\Awho\s+should\s+read\s+what\s+first\??\z/i,
  /\Ahow\s+the\s+[^?]{0,80}\s+was\s+built\??\z/i,
  /\Awhere\s+the\s+evidence\s+is\s+still\s+thin\??\z/i
].freeze

GENERIC_CONTEXT_PATTERNS = [
  /\A(is|are)\s+this\s+(review|article|page|post)\b/i,
  /\bafter\s+reading\s+this\s+(review|article|page|post)\b/i,
  /\bwhat\s+questions\s+does\b/i,
  /\bwho\s+should\s+read\b/i,
  /\bwhere\s+the\s+evidence\s+is\b/i,
  /\bhow\s+the\s+[^?]{0,80}\s+was\s+built\b/i
].freeze

def normalize_text(text)
  text.to_s.downcase.gsub(/[^a-z0-9\s]/, ' ').gsub(/\s+/, ' ').strip
end

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

failures = []

posts.each do |slug, record|
  questions = record.is_a?(Hash) ? record['questions'] : nil
  next unless questions.is_a?(Array)

  questions.each_with_index do |entry, idx|
    question = entry.is_a?(Hash) ? entry['question'].to_s.strip : ''
    answer = entry.is_a?(Hash) ? entry['answer'].to_s.strip : ''
    normalized = normalize_text(question)

    if question.length < MIN_QUESTION_LENGTH
      failures << "#{slug} [Q#{idx + 1}] question too short: #{question.inspect}"
    end

    if GENERIC_QUESTION_PATTERNS.any? { |pattern| question.match?(pattern) } ||
       GENERIC_CONTEXT_PATTERNS.any? { |pattern| normalized.match?(pattern) }
      failures << "#{slug} [Q#{idx + 1}] generic question stem: #{question.inspect}"
    end

    if answer.length < MIN_ANSWER_LENGTH
      failures << "#{slug} [Q#{idx + 1}] answer too short: #{answer.inspect}"
    end
  end
end

if failures.empty?
  puts "FAQ quality validation passed: #{posts.length} posts checked"
  exit 0
end

warn 'FAQ quality validation failed:'
failures.each { |failure| warn "- #{failure}" }
exit 1
