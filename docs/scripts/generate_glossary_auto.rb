#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'time'

ROOT = File.expand_path('..', __dir__)
SEO_AUTO_FILE = File.join(ROOT, '_data', 'seo_auto.yml')
GLOSSARY_FILE = File.join(ROOT, '_data', 'glossary_terms.yml')
OUTPUT_FILE = File.join(ROOT, '_data', 'glossary_auto.yml')

STOP_WORDS = %w[
  data model page post site article content section system process example
  engineering governance legal policy ai cloud software terms definitions
  analysis review practice contexts sourced related quick verification exploration
].to_h { |w| [w, true] }

ACRONYMS = %w[AEO AI API CVE GEO LLM ML NLP PROV SBOM SDK SEO SLA SLO SLSA]


def load_yaml(path)
  return {} unless File.exist?(path)

  YAML.safe_load(File.read(path), aliases: true) || {}
rescue StandardError
  {}
end


def normalize_term(term)
  term.to_s.gsub(/\s+/, ' ').strip
end


def title_case(term)
  words = normalize_term(term).split(' ')
  words.map do |word|
    up = word.upcase
    next up if ACRONYMS.include?(up)
    next word if word.match?(/\A[A-Z][a-z]+\z/)

    word.capitalize
  end.join(' ')
end


def quality_term?(term)
  value = normalize_term(term)
  return false if value.empty?
  return false if value.length < 4 || value.length > 72
  return false if value.match?(/^\d+$/)
  return false if value.split(' ').all? { |word| STOP_WORDS[word.downcase] }

  words = value.split(' ')
  return false if words.length > 6
  return false if words.any? { |word| word.length < 2 }

  true
end


def candidate_score(term, frequency)
  score = frequency.to_i
  score += 3 if term.match?(/\b(llm|seo|geo|aeo|provenance|sovereignty|deadlock|alignment|supply chain|token|graph)\b/i)
  score += 2 if term.split(' ').length.between?(1, 3)
  score += 1 if term.match?(/[A-Z]{2,}/)
  score
end


def collect_related_records(term, post_records, page_records)
  token = term.downcase

  related_posts = post_records.filter_map do |_slug, record|
    title = record['title'].to_s
    keywords = Array(record['keywords']).join(' ')
    phrases = Array(record['key_phrases']).join(' ')
    next unless "#{title} #{keywords} #{phrases}".downcase.include?(token)

    {
      'title' => title,
      'url' => record['url']
    }
  end

  related_pages = page_records.filter_map do |_key, record|
    title = record['title'].to_s
    keywords = Array(record['keywords']).join(' ')
    phrases = Array(record['key_phrases']).join(' ')
    next unless "#{title} #{keywords} #{phrases}".downcase.include?(token)

    {
      'title' => title,
      'url' => record['url']
    }
  end

  [related_posts.first(4), related_pages.first(3)]
end


def normalize_status(value)
  status = value.to_s.strip.downcase
  return 'approved' if status == 'approved'
  return 'rejected' if status == 'rejected'
  return 'archived' if status == 'archived'

  'candidate'
end


def deep_copy(value)
  Marshal.load(Marshal.dump(value))
rescue StandardError
  value
end


def merge_with_existing_candidate(generated, existing)
  merged = deep_copy(generated)
  return merged unless existing.is_a?(Hash)

  status = normalize_status(existing['status'])
  merged['status'] = status

  existing_definition = existing['suggested_definition'].to_s.strip
  merged['suggested_definition'] = existing_definition unless existing_definition.empty?

  merged['source'] = deep_copy(existing['source']) if existing['source'].is_a?(Hash) && !existing['source'].empty?
  merged['related_posts'] = deep_copy(existing['related_posts']) if existing['related_posts'].is_a?(Array)
  merged['related_pages'] = deep_copy(existing['related_pages']) if existing['related_pages'].is_a?(Array)

  merged['confidence'] = existing['confidence'] if existing.key?('confidence')

  merged
end

seo_auto = load_yaml(SEO_AUTO_FILE)
manual_glossary = load_yaml(GLOSSARY_FILE)
existing_glossary_auto = load_yaml(OUTPUT_FILE)

post_records = seo_auto['posts'].is_a?(Hash) ? seo_auto['posts'] : {}
page_records = seo_auto['pages'].is_a?(Hash) ? seo_auto['pages'] : {}

existing_terms = Array(manual_glossary).map { |item| normalize_term(item['term']).downcase }
existing_auto_candidates = Array(existing_glossary_auto['candidates'])

existing_auto_by_term = {}
existing_auto_candidates.each do |entry|
  next unless entry.is_a?(Hash)

  key = normalize_term(entry['term']).downcase
  next if key.empty?

  existing_auto_by_term[key] = entry
end

candidate_freq = Hash.new(0)

Array(seo_auto['key_phrases']).each { |phrase| candidate_freq[normalize_term(phrase)] += 2 }
Array(seo_auto['keywords']).each { |keyword| candidate_freq[normalize_term(keyword)] += 1 }
Array(seo_auto['search_words']).each { |query| candidate_freq[normalize_term(query)] += 1 }

(post_records.values + page_records.values).each do |record|
  Array(record['keywords']).each { |keyword| candidate_freq[normalize_term(keyword)] += 1 }
  Array(record['key_phrases']).each { |phrase| candidate_freq[normalize_term(phrase)] += 2 }
end

generated_candidates = candidate_freq
  .select { |term, _| quality_term?(term) }
  .reject { |term, _| existing_terms.include?(term.downcase) }
  .map do |term, freq|
    normalized = title_case(term)
    related_posts, related_pages = collect_related_records(normalized, post_records, page_records)

    {
      'term' => normalized,
      'status' => 'candidate',
      'confidence' => candidate_score(normalized, freq),
      'suggested_definition' => 'Auto-extracted terminology candidate derived from site content signals. Editorial review is required before promotion to glossary_terms.yml.',
      'source' => {
        'label' => 'Auto extraction from site corpus',
        'url' => '/faq/',
        'tier' => 'Internal synthesis (automated candidate)'
      },
      'related_posts' => related_posts,
      'related_pages' => related_pages
    }
  end
  .sort_by { |item| [-item['confidence'], item['term']] }
  .first(200)

generated_by_term = {}
generated_candidates.each do |entry|
  key = normalize_term(entry['term']).downcase
  generated_by_term[key] = entry
end

merged_candidates = generated_candidates.map do |entry|
  key = normalize_term(entry['term']).downcase
  merge_with_existing_candidate(entry, existing_auto_by_term[key])
end

# Keep existing moderated entries even if they are not re-extracted in the latest run.
existing_auto_by_term.each do |key, entry|
  next if generated_by_term.key?(key)

  status = normalize_status(entry['status'])
  next unless %w[approved rejected archived candidate].include?(status)

  preserved = deep_copy(entry)
  preserved['status'] = status
  merged_candidates << preserved
end

status_order = { 'approved' => 0, 'candidate' => 1, 'rejected' => 2, 'archived' => 3 }

candidates = merged_candidates
  .uniq { |entry| normalize_term(entry['term']).downcase }
  .sort_by do |entry|
    [
      status_order.fetch(normalize_status(entry['status']), 9),
      -entry['confidence'].to_i,
      normalize_term(entry['term'])
    ]
  end

payload = {
  'generated_at' => Time.now.utc.iso8601,
  'total_candidates' => candidates.length,
  'candidates' => candidates
}

File.write(OUTPUT_FILE, payload.to_yaml(line_width: -1))
puts "Generated #{OUTPUT_FILE} with #{candidates.length} glossary candidates"
