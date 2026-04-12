#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'time'
require 'date'

ROOT = File.expand_path('..', __dir__)
POSTS_DIR = File.join(ROOT, '_posts')
OUTPUT_FILE = File.join(ROOT, '_data', 'seo_auto.yml')

STOP_WORDS = %w[
  a an and are as at be been being but by can could did do does doing for from
  had has have having he her here hers herself him himself his how i if in into
  is it its itself just me more most my myself no nor not of off on once only or
  other our ours ourselves out over own same she should so some such than that
  the their theirs them themselves then there these they this those through to too
  under until up very was we were what when where which while who whom why will
  with you your yours yourself yourselves about after again against all also any
  because before between both during each few further many might must shall would
  whose across via per onto upon within without
].to_h { |w| [w, true] }

BLOCKED_TOKENS = %w[
  include references cite html key ref refs markdown liquid yaml json url https http
  www com org net io dev now then such section page post posts article articles
].to_h { |w| [w, true] }

QUESTION_PREFIX = /^(who|what|why|how|when|where|can|should|is|are|do|does|did|will)\b/i

def split_front_matter(raw)
  return [{}, raw] unless raw.start_with?("---\n")

  parts = raw.split(/^---\s*$\n?/, 3)
  return [{}, raw] if parts.length < 3

  front = YAML.safe_load(parts[1], permitted_classes: [Time, Date], aliases: true) || {}
  [front, parts[2] || '']
end

def normalize_text(text)
  value = text.to_s.dup
  value.gsub!(/\{\%.*?\%\}/m, ' ')
  value.gsub!(/\{\{.*?\}\}/m, ' ')
  value.gsub!(/```.*?```/m, ' ')
  value.gsub!(/`[^`]*`/, ' ')
  value.gsub!(/!\[[^\]]*\]\([^\)]*\)/, ' ')
  value.gsub!(/\[([^\]]+)\]\([^\)]*\)/, '\\1')
  value.gsub!(/<[^>]+>/, ' ')
  value.gsub!(/[#>*_~\-|]/, ' ')
  value.gsub!(/[^a-zA-Z0-9\s]/, ' ')
  value.downcase.gsub(/\s+/, ' ').strip
end

def tokenize(text)
  normalize_text(text).split(' ').select do |w|
    next false if w.length < 3 || w.length > 24
    next false if STOP_WORDS[w] || BLOCKED_TOKENS[w]
    next false if w.match?(/^\d+$/)
    next false if w.match?(/^ref\d+$/)
    next false if w.match?(/^\d{4}$/)
    next false if w.match?(/\A[^a-z]+\z/)

    true
  end
end

def post_slug(file_path)
  File.basename(file_path).sub(/^\d{4}-\d{2}-\d{2}-/, '').sub(/\.[^.]+$/, '')
end

def post_url(file_path)
  filename = File.basename(file_path).sub(/\.[^.]+$/, '')
  date_part = filename[0, 10]
  slug_part = filename[11..]
  date_tokens = date_part.split('-')
  "/#{date_tokens[0]}/#{date_tokens[1]}/#{date_tokens[2]}/#{slug_part}.html"
end

def heading_questions(markdown)
  lines = markdown.lines
  qa = []

  lines.each_with_index do |line, idx|
    next unless line =~ /^\#{2,6}\s+(.+)$/

    heading = Regexp.last_match(1).strip
    clean_heading = heading.gsub(/\{:.+\}$/, '').strip
    is_question = clean_heading.end_with?('?') || clean_heading.match?(QUESTION_PREFIX)
    next unless is_question

    answer_lines = []
    j = idx + 1
    while j < lines.length
      current = lines[j]
      break if current =~ /^\#{1,6}\s+/ || current.strip.start_with?('---')

      text = current.strip
      answer_lines << text unless text.empty?
      break if answer_lines.length >= 2
      j += 1
    end

    answer = answer_lines.join(' ')
    answer = 'See the section in the article for details.' if answer.empty?
    qa << { 'question' => clean_heading, 'answer' => answer }
  end

  qa.uniq { |item| item['question'].downcase }
end

word_freq = Hash.new(0)
phrase_freq = Hash.new(0)
catchphrase_freq = Hash.new(0)
post_records = {}

Dir.glob(File.join(POSTS_DIR, '*.{md,markdown}')).sort.each do |path|
  raw = File.read(path)
  front, body = split_front_matter(raw)

  title = front['title'].to_s
  description = front['description'].to_s
  intro = front['intro'].to_s
  tags = Array(front['tags']).map(&:to_s)
  categories = Array(front['categories']).map(&:to_s)

  source_text = [title, description, intro, tags.join(' '), categories.join(' '), body].join("\n")
  tokens = tokenize(source_text)
  local_phrase_freq = Hash.new(0)
  tokens.each { |w| word_freq[w] += 1 }

  # Build bigrams and trigrams for key phrases / catchphrases.
  (0...(tokens.length - 1)).each do |i|
    bigram = "#{tokens[i]} #{tokens[i + 1]}"
    phrase_freq[bigram] += 1
    local_phrase_freq[bigram] += 1
  end
  (0...(tokens.length - 2)).each do |i|
    trigram = "#{tokens[i]} #{tokens[i + 1]} #{tokens[i + 2]}"
    phrase_freq[trigram] += 1
    local_phrase_freq[trigram] += 1
  end

  # Catchphrases from headings and title fragments.
  heading_lines = body.lines.select { |line| line =~ /^\#{1,3}\s+/ }
  heading_lines.each do |line|
    phrase = normalize_text(line.sub(/^\#{1,6}\s+/, '')).strip
    next if phrase.empty?

    words = phrase.split(' ')
    next if words.length < 2
    next if words.any? { |w| STOP_WORDS[w] || BLOCKED_TOKENS[w] || w.match?(/^ref\d+$/) }

    catchphrase_freq[phrase] += 1
  end

  post_key_terms = tokens.tally.sort_by { |term, count| [-count, term] }.map(&:first).first(24)
  post_phrases = local_phrase_freq.select { |k, _| k.split(' ').length >= 2 && post_key_terms.any? { |t| k.include?(t) } }
                               .sort_by { |_, count| -count }
                           .map(&:first)
                           .first(16)

  slug = front['slug'].to_s.strip
  slug = post_slug(path) if slug.empty?

  post_records[slug] = {
    'url' => front['permalink'].to_s.empty? ? post_url(path) : front['permalink'].to_s,
    'keywords' => (post_key_terms + tags + categories).map(&:to_s).map(&:downcase).uniq.first(30),
    'key_phrases' => post_phrases,
    'questions' => heading_questions(body)
  }
end

global_keywords = word_freq.sort_by { |term, count| [-count, term] }.map(&:first).first(120)
global_key_phrases = phrase_freq.select do |phrase, count|
  next false unless count > 1

  words = phrase.split(' ')
  next false if words.length < 2 || words.length > 5
  next false if words.any? { |w| w.length < 3 || STOP_WORDS[w] || BLOCKED_TOKENS[w] || w.match?(/^ref\d+$/) || w.match?(/^\d+$/) }

  true
end
                                .sort_by { |phrase, count| [-count, phrase] }
                                .map(&:first)
                                .first(120)
global_catchphrases = catchphrase_freq.select do |phrase, _|
  words = phrase.split(' ')
  words.length.between?(2, 12) && words.none? { |w| BLOCKED_TOKENS[w] || w.match?(/^ref\d+$/) }
end.sort_by { |phrase, count| [-count, phrase] }.map(&:first).first(80)
global_catchwords = global_keywords.select { |w| w.length >= 5 }.first(120)

payload = {
  'generated_at' => Time.now.utc.iso8601,
  'keywords' => global_keywords,
  'key_phrases' => global_key_phrases,
  'catchwords' => global_catchwords,
  'catchphrases' => global_catchphrases,
  'posts' => post_records
}

File.write(OUTPUT_FILE, payload.to_yaml(line_width: -1))
puts "Generated #{OUTPUT_FILE} with #{post_records.size} post profiles"
