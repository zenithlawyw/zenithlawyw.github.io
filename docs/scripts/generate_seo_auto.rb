#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'time'
require 'date'
require 'set'

ROOT = File.expand_path('..', __dir__)
POSTS_DIR = File.join(ROOT, '_posts')
OUTPUT_FILE = File.join(ROOT, '_data', 'seo_auto.yml')
MANAGED_STOP_WORDS_FILE = File.join(ROOT, 'scripts', 'managed_stop_words.yml')

BASE_STOP_WORDS = %w[
  a an and are as at be been being but by can could did do does doing for from
  had has have having he her here hers herself him himself his how i if in into
  is it its itself just me more most my myself no nor not of off on once only or
  other our ours ourselves out over own same she should so some such than that
  the their theirs them themselves then there these they this those through to too
  under until up very was we were what when where which while who whom why will
  with you your yours yourself yourselves about after again against all also any
  because before between both during each few further many might must shall would
  whose across via per onto upon within without
].freeze

BASE_BLOCKED_TOKENS = %w[
  include references cite html key ref refs markdown liquid yaml json url https http
  www com org net io dev now then such section page post posts article articles
  image hero layout permalink title description keywords catchwords intro
].freeze

BASE_WEAK_TOKENS = %w[
  use uses used using one source sources term terms rather time wait waits waiting
  site content text request requests require requires required including related
  available specific every build cannot may much many several various another
].freeze

QUESTION_PREFIX = /^(who|what|why|how|when|where|can|should|is|are|do|does|did|will)\b/i
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

CONTENT_EXTENSIONS = %w[md markdown html].freeze

# Taxonomy-first weighting for SEO/GEO/AEO keyword inference.
# Categories and tags are curated topical intent labels, so they should outweigh
# descriptive prose fields that are noisier and more verbose.
SIGNAL_FIELD_WEIGHTS = {
  title: 3,
  categories: 5,
  tags: 5,
  intro: 2,
  description: 2,
  headings: 2,
  keywords: 1,
  catchwords: 1
}.freeze

SIGNAL_WEIGHT_RATIONALE = {
  'categories_tags' => 'Highest weight because these fields encode editor-curated topical intent and improve stable retrieval anchors for SEO/GEO/AEO.',
  'title' => 'High but lower than taxonomy because titles can include stylistic language not intended as retrieval anchors.',
  'intro_description_headings' => 'Medium weight for context enrichment without dominating keyword extraction.',
  'keywords_catchwords' => 'Low weight to avoid over-amplifying manually supplied or potentially noisy token lists.'
}.freeze

def validate_signal_weights!
  category_weight = SIGNAL_FIELD_WEIGHTS[:categories]
  tag_weight = SIGNAL_FIELD_WEIGHTS[:tags]
  baseline_fields = %i[title intro description headings keywords catchwords]

  baseline_fields.each do |field|
    weight = SIGNAL_FIELD_WEIGHTS[field]
    next if category_weight > weight && tag_weight > weight

    raise "Signal weight profile invalid: categories/tags must be greater than #{field}"
  end
end

validate_signal_weights!


def normalize_stop_term(term)
  value = term.to_s.downcase.strip
  value = value.gsub(/\A["']+|["']+\z/, '')
  value = value.gsub(/\A\(\?i\)/, '')
  value = value.gsub(/\\b/, '')
  value = value.gsub(/\A\(+|\)+\z/, '')
  value = value.gsub(/\A[“”‘’]+|[“”‘’]+\z/, '')
  value = value.strip
  return '' if value.empty?

  value.gsub(/\s+/, ' ')
end


def extract_terms_from_regex_blob(blob)
  text = blob.to_s
  return [] if text.strip.empty?

  inner = text.dup
  inner = inner.sub(/^\s*"?\(\?i\)\\b\(/, '')
  inner = inner.sub(/\)\\b"?\s*$/, '')
  inner = inner.gsub(/^\s*"|"\s*$/, '')

  inner.split('|').map { |token| normalize_stop_term(token) }
       .reject(&:empty?)
end


def extract_terms_from_csv_blob(blob)
  text = blob.to_s
  return [] if text.strip.empty?

  text.split(',').map { |token| normalize_stop_term(token) }
      .reject(&:empty?)
end


def load_managed_stop_words(path)
  return [] unless File.exist?(path)

  raw = YAML.safe_load(File.read(path), aliases: true) || {}
  terms = []

  Array(raw['terms']).each do |item|
    terms << normalize_stop_term(item)
  end

  Array(raw['regex_sources']).each do |blob|
    terms.concat(extract_terms_from_regex_blob(blob))
  end

  Array(raw['csv_sources']).each do |blob|
    terms.concat(extract_terms_from_csv_blob(blob))
  end

  terms.reject(&:empty?).uniq
rescue StandardError
  []
end


MANAGED_STOP_WORDS = load_managed_stop_words(MANAGED_STOP_WORDS_FILE).freeze
STOP_WORDS = (BASE_STOP_WORDS + MANAGED_STOP_WORDS).to_set.freeze
BLOCKED_TOKENS = (BASE_BLOCKED_TOKENS + MANAGED_STOP_WORDS).to_set.freeze
WEAK_TOKENS = (BASE_WEAK_TOKENS + MANAGED_STOP_WORDS).to_set.freeze


def split_front_matter(raw)
  return [{}, raw] unless raw.start_with?("---\n")

  parts = raw.split(/^---\s*$\n?/, 3)
  return [{}, raw] if parts.length < 3

  front = YAML.safe_load(parts[1], permitted_classes: [Time, Date], aliases: true) || {}
  [front, parts[2] || '']
rescue StandardError
  [{}, raw]
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
  value.gsub!(/[#>*_~|]/, ' ')
  value.gsub!(/[^a-zA-Z0-9\s\-]/, ' ')
  value.downcase.gsub(/\s+/, ' ').strip
end


def strip_html_tags(text)
  text.to_s.gsub(/<[^>]+>/, ' ')
end


def extract_heading_phrases(content)
  body = content.to_s
  headings = []

  body.lines.each do |line|
    next unless line =~ /^\#{1,6}\s+(.+)$/

    text = Regexp.last_match(1).to_s
    text = text.sub(/\{:.+\}\s*\z/, '').strip
    phrase = normalize_text(text)
    headings << phrase unless phrase.empty?
  end

  body.scan(/<h[1-6][^>]*>(.*?)<\/h[1-6]>/im).each do |match|
    raw = match.is_a?(Array) ? match.first : match
    phrase = normalize_text(strip_html_tags(raw))
    headings << phrase unless phrase.empty?
  end

  headings.uniq
end


def build_signal_text(fields)
  title = fields[:title].to_s
  description = fields[:description].to_s
  intro = fields[:intro].to_s
  tags = Array(fields[:tags]).map(&:to_s)
  categories = Array(fields[:categories]).map(&:to_s)
  keywords = Array(fields[:keywords]).map(&:to_s)
  catchwords = Array(fields[:catchwords]).map(&:to_s)
  headings = Array(fields[:headings]).map(&:to_s)

  # Apply explicit field weights so curated taxonomy labels dominate.
  segments = []

  {
    title: title,
    categories: categories.join(' '),
    tags: tags.join(' '),
    intro: intro,
    description: description,
    headings: headings.join(' '),
    keywords: keywords.join(' '),
    catchwords: catchwords.join(' ')
  }.each do |field, text|
    next if text.strip.empty?

    SIGNAL_FIELD_WEIGHTS.fetch(field, 1).times { segments << text }
  end

  segments.join("\n")
end


def clean_sentence(text)
  value = text.to_s.dup
  value.gsub!(/\{\%\s*include\s+references\/cite\.html[^%]*\%\}/m, ' ')
  value.gsub!(/\{\%.*?\%\}/m, ' ')
  value.gsub!(/\{\{.*?\}\}/m, ' ')
  value.gsub!(/\s+/, ' ')
  value.gsub!(/\s+([,.;:!?])/, '\\1')
  value.gsub!(/,\s*(,\s*)+/, ', ')
  value.gsub!(/([.!?])\s*([.!?])+/, '\\1')
  value.gsub!(/,\s*([.!?])/, '\\1')
  value.gsub!(/\(\s+/, '(')
  value.gsub!(/\s+\)/, ')')
  value.gsub!(/[,:;\-]\s*\z/, '')
  value.gsub!(/\s+/, ' ')
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


def tokenize(text)
  normalize_text(text).split(' ').select do |word|
    next false if word.length < 3 || word.length > 32
    next false if STOP_WORDS.include?(word) || BLOCKED_TOKENS.include?(word)
    next false if WEAK_TOKENS.include?(word)
    next false if word.match?(/^\d+$/)
    next false if word.match?(/^ref\d+$/)
    next false if word.match?(/^\d{4}$/)
    next false if word.match?(/\A[^a-z]+\z/)

    true
  end
end


def normalize_word_key(word)
  token = word.to_s.downcase.strip
  return '' if token.empty?

  token = token.sub(/ies\z/, 'y') if token.length > 4
  token = token.sub(/ing\z/, '') if token.length > 6
  token = token.sub(/ed\z/, '') if token.length > 5
  token = token.sub(/es\z/, '') if token.length > 5
  token = token.sub(/s\z/, '') if token.length > 4

  token
end


def semantic_term_key(term)
  words = normalize_text(term).split(' ')
  words.map { |word| normalize_word_key(word) }
       .reject(&:empty?)
       .join(' ')
       .strip
end


def quality_term?(term)
  words = normalize_text(term).split(' ')
  return false if words.empty?
  return false if words.all? { |w| STOP_WORDS.include?(w) || BLOCKED_TOKENS.include?(w) || WEAK_TOKENS.include?(w) }

  if words.length == 1
    word = words.first
    return false if STOP_WORDS.include?(word) || BLOCKED_TOKENS.include?(word) || WEAK_TOKENS.include?(word)
  end

  true
end


def clean_and_dedupe_terms(items, limit)
  seen = {}
  output = []

  Array(items).each do |item|
    raw = item.to_s.strip.downcase
    next if raw.empty?
    next unless quality_term?(raw)

    key = semantic_term_key(raw)
    next if key.empty? || seen[key]

    seen[key] = true
    output << raw
    break if output.length >= limit
  end

  output
end


def quality_question?(question)
  normalized = normalize_text(question)
  return false if question.empty?
  return false if question.length < 24 || question.length > 320
  return false unless question.end_with?('?') || question.match?(QUESTION_PREFIX)
  return false if GENERIC_QUESTION_PATTERNS.any? { |pattern| question.match?(pattern) }
  return false if GENERIC_CONTEXT_PATTERNS.any? { |pattern| normalized.match?(pattern) }

  true
end


def quality_answer?(answer)
  return false if answer.empty?
  return false if answer.length < 55
  return false if answer.match?(/\Asee\s+the\s+section\b/i)

  true
end


def question_score(question)
  score = 0
  score += 3 if question.match?(/\Awhat\b/i)
  score += 3 if question.match?(/\Ahow\b/i)
  score += 2 if question.match?(/\Awhy\b/i)
  score += 1 if question.match?(/\A(can|should|is|are|do|does|did|will)\b/i)
  score += 2 if question.length.between?(24, 120)
  score
end


def answer_score(answer)
  score = 0
  score += 2 if answer.length.between?(60, 420)
  score += 1 if answer.match?(/[.!?]/)
  score += 1 if answer.match?(/\b(source|evidence|because|therefore|for example|includes?)\b/i)
  score
end


def heading_questions(markdown)
  lines = markdown.lines
  qa = []
  in_faq_section = false

  lines.each_with_index do |line, index|
    next unless line =~ /^(\#{2,6})\s+(.+)$/

    level = Regexp.last_match(1).length
    heading_text = Regexp.last_match(2).to_s

    if level == 2
      normalized_h2 = normalize_text(heading_text)
      in_faq_section = normalized_h2.include?('frequently asked questions')
      next
    end

    next unless in_faq_section
    next unless level >= 3

    heading = normalize_question(heading_text)
    next unless quality_question?(heading)

    answer_lines = []
    i = index + 1
    while i < lines.length
      current = lines[i]
      break if current =~ /^\#{1,6}\s+/ || current.strip.start_with?('---')

      stripped = current.strip
      unless stripped.empty?
        answer_lines << stripped
      end
      break if answer_lines.length >= 3

      i += 1
    end

    answer = clean_sentence(answer_lines.join(' '))
    next unless quality_answer?(answer)

    qa << { 'question' => heading, 'answer' => answer }
  end

  qa
end


def heading_questions_anywhere(markdown)
  lines = markdown.lines
  qa = []

  lines.each_with_index do |line, index|
    next unless line =~ /^\#{2,6}\s+(.+)$/

    heading = normalize_question(Regexp.last_match(1).to_s)
    next unless quality_question?(heading)

    answer_lines = []
    i = index + 1
    while i < lines.length
      current = lines[i]
      break if current =~ /^\#{1,6}\s+/ || current.strip.start_with?('---')

      stripped = current.strip
      answer_lines << stripped unless stripped.empty?
      break if answer_lines.length >= 3

      i += 1
    end

    answer = clean_sentence(answer_lines.join(' '))
    next unless quality_answer?(answer)

    qa << { 'question' => heading, 'answer' => answer }
  end

  qa
end


def dedupe_questions_preserve_order(questions, limit)
  seen = {}
  output = []

  questions.each do |item|
    key = item['question'].downcase.gsub(/\s+/, ' ').strip
    next if seen[key]

    seen[key] = true
    output << item
    break if output.length >= limit
  end

  output
end


def frontmatter_questions(front)
  faq = front['faq']
  return [] unless faq.is_a?(Array)

  faq.filter_map do |item|
    next unless item.is_a?(Hash)

    question = normalize_question(item['question'])
    answer = clean_sentence(item['answer'])
    next unless quality_question?(question)
    next unless quality_answer?(answer)

    { 'question' => question, 'answer' => answer }
  end
end


def dedupe_and_rank_questions(questions, limit)
  seen = {}
  questions.each do |item|
    key = item['question'].downcase.gsub(/\s+/, ' ').strip
    score = question_score(item['question']) + answer_score(item['answer'])
    if !seen.key?(key) || seen[key]['_score'] < score
      seen[key] = item.merge('_score' => score)
    end
  end

  seen.values.sort_by { |item| [-item['_score'], item['question']] }
      .first(limit)
      .map { |item| item.reject { |k, _| k == '_score' } }
end


def content_files
  patterns = CONTENT_EXTENSIONS.map { |ext| File.join(ROOT, "**/*.#{ext}") }
  patterns.flat_map { |pattern| Dir.glob(pattern) }
          .uniq
          .reject do |path|
            path.include?('/_site/') ||
              path.include?('/assets/') ||
              path.include?('/vendor/') ||
              path.include?('/scripts/')
          end
end


def page_key_from_url(url)
  parts = url.to_s.split('/').reject(&:empty?)
  return '' if parts.empty?

  candidate = parts.last
  candidate = parts[-2] if candidate == 'index.html' && parts.length > 1
  candidate.to_s.sub(/\.html$/, '')
end


def post_slug(path)
  File.basename(path).sub(/^\d{4}-\d{2}-\d{2}-/, '').sub(/\.[^.]+$/, '')
end


def fallback_url(path)
  relative = path.sub(ROOT + '/', '')
  "/#{relative.sub(/\.(md|markdown)$/, '.html')}"
end


def normalize_url(front, path)
  permalink = front['permalink'].to_s.strip
  return permalink unless permalink.empty?

  if path.include?('/_posts/')
    filename = File.basename(path).sub(/\.[^.]+$/, '')
    date_part = filename[0, 10]
    slug_part = filename[11..]
    date_tokens = date_part.split('-')
    return "/#{date_tokens[0]}/#{date_tokens[1]}/#{date_tokens[2]}/#{slug_part}.html"
  end

  fallback_url(path)
end


def update_ngrams(tokens, global_phrase_freq, local_phrase_freq)
  (0...(tokens.length - 1)).each do |i|
    bigram = "#{tokens[i]} #{tokens[i + 1]}"
    global_phrase_freq[bigram] += 1
    local_phrase_freq[bigram] += 1
  end

  (0...(tokens.length - 2)).each do |i|
    trigram = "#{tokens[i]} #{tokens[i + 1]} #{tokens[i + 2]}"
    global_phrase_freq[trigram] += 1
    local_phrase_freq[trigram] += 1
  end
end


def quality_phrase?(phrase, count)
  return false unless count > 1

  words = phrase.split(' ')
  return false if words.length < 2 || words.length > 5
  return false if words.any? { |word| word.length < 3 }
  return false if words.any? { |word| STOP_WORDS.include?(word) || BLOCKED_TOKENS.include?(word) || WEAK_TOKENS.include?(word) }
  return false if words.any? { |word| word.match?(/^ref\d+$/) || word.match?(/^\d+$/) }

  true
end

word_freq = Hash.new(0)
phrase_freq = Hash.new(0)
catchphrase_freq = Hash.new(0)
records_by_path = {}

content_files.each do |path|
  raw = File.read(path)
  front, body = split_front_matter(raw)

  title = front['title'].to_s
  description = front['description'].to_s
  intro = front['intro'].to_s
  tags = Array(front['tags']).map(&:to_s)
  categories = Array(front['categories']).map(&:to_s)
  keywords = Array(front['keywords']).flat_map { |v| v.to_s.split(',') }.map(&:strip)
  catchwords = Array(front['catchwords']).flat_map { |v| v.to_s.split(',') }.map(&:strip)
  headings = extract_heading_phrases(body)

  source_text = build_signal_text(
    title: title,
    description: description,
    intro: intro,
    tags: tags,
    categories: categories,
    keywords: keywords,
    catchwords: catchwords,
    headings: headings
  )

  tokens = tokenize(source_text)
  local_phrase_freq = Hash.new(0)
  tokens.each { |word| word_freq[word] += 1 }
  update_ngrams(tokens, phrase_freq, local_phrase_freq)

  headings.each do |phrase|
    next if phrase.empty?

    words = phrase.split(' ')
    next if words.length < 2 || words.length > 12
    next if words.any? { |w| STOP_WORDS.include?(w) || BLOCKED_TOKENS.include?(w) || w.match?(/^ref\d+$/) }

    catchphrase_freq[phrase] += 1
  end

  local_terms = tokens.tally.sort_by { |term, count| [-count, term] }.map(&:first).first(36)
  local_phrases = local_phrase_freq.select { |k, _| k.split(' ').length >= 2 && local_terms.any? { |term| k.include?(term) } }
                                 .sort_by { |_, count| -count }
                                 .map(&:first)
                                 .first(24)

  section_questions = heading_questions(body)
  fallback_questions = section_questions.empty? ? heading_questions_anywhere(body) : []

  extracted_questions = dedupe_questions_preserve_order(
    frontmatter_questions(front) + section_questions + fallback_questions,
    16
  )

  records_by_path[path] = {
    'path' => path,
    'is_post' => path.include?('/_posts/'),
    'title' => title,
    'slug' => front['slug'].to_s.strip,
    'url' => normalize_url(front, path),
    'keywords' => clean_and_dedupe_terms(local_terms + tags + categories + keywords + catchwords, 40),
    'key_phrases' => clean_and_dedupe_terms(local_phrases, 24),
    'catchwords' => clean_and_dedupe_terms(local_terms.select { |w| w.length >= 5 }, 28),
    'search_words' => clean_and_dedupe_terms(local_terms.first(18) + local_phrases.first(12), 30),
    'questions' => extracted_questions
  }
end

global_keywords = clean_and_dedupe_terms(
  word_freq.sort_by { |term, count| [-count, term] }
          .map(&:first),
  160
)
global_key_phrases = clean_and_dedupe_terms(
  phrase_freq.select { |phrase, count| quality_phrase?(phrase, count) }
            .sort_by { |phrase, count| [-count, phrase] }
            .map(&:first),
  140
)
global_catchphrases = clean_and_dedupe_terms(
  catchphrase_freq.select do |phrase, _|
  words = phrase.split(' ')
  words.length.between?(2, 12) &&
    words.none? { |w| BLOCKED_TOKENS.include?(w) || WEAK_TOKENS.include?(w) || w.match?(/^ref\d+$/) }
  end
  .sort_by { |phrase, count| [-count, phrase] }
  .map(&:first),
  100
)
global_catchwords = clean_and_dedupe_terms(global_keywords.select { |w| w.length >= 5 }, 160)
global_search_words = clean_and_dedupe_terms(global_keywords.first(90) + global_key_phrases.first(70), 180)

post_records = {}
page_records = {}

records_by_path.values.each do |record|
  if record['is_post']
    slug = record['slug']
    slug = post_slug(record['path']) if slug.empty?
    post_records[slug] = record.reject { |k, _| %w[path is_post slug].include?(k) }
  else
    key = record['slug']
    key = page_key_from_url(record['url']) if key.empty?
    next if key.empty?

    page_records[key] = record.reject { |k, _| %w[path is_post slug].include?(k) }
  end
end

all_questions = post_records.values
  .flat_map { |entry| entry['questions'] }

all_questions = dedupe_and_rank_questions(all_questions, 250)

payload = {
  'generated_at' => Time.now.utc.iso8601,
  'signal_weights' => SIGNAL_FIELD_WEIGHTS.transform_keys(&:to_s),
  'signal_weight_rationale' => SIGNAL_WEIGHT_RATIONALE,
  'keywords' => global_keywords,
  'key_phrases' => global_key_phrases,
  'catchwords' => global_catchwords,
  'catchphrases' => global_catchphrases,
  'search_words' => global_search_words,
  'global_questions' => all_questions,
  'posts' => post_records,
  'pages' => page_records
}

File.write(OUTPUT_FILE, payload.to_yaml(line_width: -1))
puts "Generated #{OUTPUT_FILE} with #{post_records.size} post profiles and #{page_records.size} page profiles"
