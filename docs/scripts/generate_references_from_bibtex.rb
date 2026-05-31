#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "yaml"

ROOT = File.expand_path("..", __dir__)
BIB_FILE = File.join(ROOT, "_data", "references.bib")
OUTPUT_FILE = File.join(ROOT, "_data", "references_generated.yml")

MONTH_LOOKUP = {
  "jan" => 1, "january" => 1,
  "feb" => 2, "february" => 2,
  "mar" => 3, "march" => 3,
  "apr" => 4, "april" => 4,
  "may" => 5,
  "jun" => 6, "june" => 6,
  "jul" => 7, "july" => 7,
  "aug" => 8, "august" => 8,
  "sep" => 9, "sept" => 9, "september" => 9,
  "oct" => 10, "october" => 10,
  "nov" => 11, "november" => 11,
  "dec" => 12, "december" => 12
}.freeze

ENTRY_TYPE_ALIAS = {
  "conference" => "inproceedings",
  "proceedings" => "proceedings",
  "inproceedings" => "inproceedings",
  "incollection" => "incollection",
  "article" => "article",
  "book" => "book",
  "booklet" => "booklet",
  "manual" => "manual",
  "mastersthesis" => "mastersthesis",
  "phdthesis" => "phdthesis",
  "techreport" => "techreport",
  "unpublished" => "unpublished",
  "misc" => "misc",
  "online" => "online"
}.freeze

def clean_value(value)
  return "" if value.nil?

  text = value.to_s.strip
  text = text[1..-2].to_s.strip if text.start_with?("{") && text.end_with?("}")
  text = text[1..-2].to_s.strip if text.start_with?("\"") && text.end_with?("\"")
  text.gsub(/\s+/, " ").strip
end

def parse_iso_date(value)
  text = clean_value(value)
  return nil if text.empty?

  # YYYY-MM-DD
  return text if text.match?(/\A\d{4}-\d{2}-\d{2}\z/)

  # YYYY/MM/DD
  if text.match?(/\A(\d{4})\/(\d{1,2})\/(\d{1,2})\z/)
    return format("%04d-%02d-%02d", Regexp.last_match(1).to_i, Regexp.last_match(2).to_i, Regexp.last_match(3).to_i)
  end

  # DD MMM YYYY
  if text.match?(/\A(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})\z/)
    day = Regexp.last_match(1).to_i
    month_name = Regexp.last_match(2).downcase
    year = Regexp.last_match(3).to_i
    month = MONTH_LOOKUP[month_name]
    return nil unless month

    return format("%04d-%02d-%02d", year, month, day)
  end

  # MMM YYYY
  if text.match?(/\A([A-Za-z]+)\s+(\d{4})\z/)
    month_name = Regexp.last_match(1).downcase
    year = Regexp.last_match(2).to_i
    month = MONTH_LOOKUP[month_name]
    return nil unless month

    return format("%04d-%02d-01", year, month)
  end

  # YYYY
  if text.match?(/\A\d{4}\z/)
    year = text.to_i
    return format("%04d-01-01", year)
  end

  nil
end

def format_human_date(iso_date)
  return nil if iso_date.nil? || iso_date.empty?

  Date.strptime(iso_date, "%Y-%m-%d").strftime("%-d %B %Y")
rescue StandardError
  nil
end

def parse_accessed_date_from_text(text)
  return nil unless text

  match = text.match(/Accessed:\s*(\d{1,2}\s+[A-Za-z]+\s+\d{4})\.?/i)
  return nil unless match

  Date.strptime(match[1], "%d %B %Y")
rescue StandardError
  nil
end

def extract_url_from_text(text)
  return nil unless text

  markdown_link = text.match(/\[https?:\/\/[^\]]+\]\((https?:\/\/[^)]+)\)/)
  return markdown_link[1].to_s.strip if markdown_link

  plain_link = text.match(/(https?:\/\/[^\s\])"']+)/)
  return plain_link[1].to_s.strip if plain_link

  nil
end

def split_authors(author_field)
  clean_value(author_field).split(/\s+and\s+/i).map(&:strip).reject(&:empty?)
end

# Convert "Surname, Firstname Middlename" → "Surname, F.M."
# or "Firstname Surname" (no comma) → "Surname, F."
def harvard_author_name(name)
  name = name.strip
  if name.include?(",")
    parts = name.split(",", 2)
    surname = parts[0].strip
    given = parts[1].to_s.strip
    initials = given.split(/[\s.-]+/).reject(&:empty?).map { |g| "#{g[0]}." }.join("")
    initials.empty? ? surname : "#{surname}, #{initials}"
  else
    tokens = name.split(/\s+/)
    return name if tokens.length < 2

    surname = tokens.last
    initials = tokens[0..-2].map { |g| "#{g[0]}." }.join("")
    "#{surname}, #{initials}"
  end
end

# Convert "Surname, Firstname" → "F. Surname"
# or "Firstname Surname" → "F. Surname"
def ieee_author_name(name)
  name = name.strip
  if name.include?(",")
    parts = name.split(",", 2)
    surname = parts[0].strip
    given = parts[1].to_s.strip
    initials = given.split(/[\s.-]+/).reject(&:empty?).map { |g| "#{g[0]}." }.join(" ")
    initials.empty? ? surname : "#{initials} #{surname}"
  else
    tokens = name.split(/\s+/)
    return name if tokens.length < 2

    surname = tokens.last
    initials = tokens[0..-2].map { |g| "#{g[0]}." }.join(" ")
    "#{initials} #{surname}"
  end
end

# Format author list for Harvard style:
# 1-3 authors: list all as Surname, F.
# 4+ authors:  first author et al.
def format_authors_harvard(author_field)
  names = split_authors(author_field).map { |n| harvard_author_name(n) }
  return "" if names.empty?
  return names.first if names.length == 1
  return "#{names[0]} and #{names[1]}" if names.length == 2
  return "#{names[0..-2].join(', ')} and #{names.last}" if names.length <= 3

  "#{names.first} et al."
end

# Format author list for IEEE style:
# 1-6 authors: list all as F. Surname
# 7+ authors:  first author et al.
def format_authors_ieee(author_field)
  names = split_authors(author_field).map { |n| ieee_author_name(n) }
  return "" if names.empty?
  return names.first if names.length == 1
  return "#{names[0]} and #{names[1]}" if names.length == 2
  return "#{names[0..-2].join(', ')} and #{names.last}" if names.length <= 6

  "#{names.first} et al."
end

def short_author_from(authors)
  return nil if authors.empty?

  if authors.length == 1
    surname = authors.first.split(",").first.to_s.strip
    return surname unless surname.empty?

    return authors.first
  end

  first_surname = authors.first.split(",").first.to_s.strip
  first_surname = authors.first if first_surname.empty?
  "#{first_surname} et al."
end

def entry_year(fields)
  year_text = clean_value(fields["year"])
  return year_text unless year_text.empty?

  published_iso = parse_iso_date(fields["date"])
  return "n.d." unless published_iso

  published_iso[0, 4]
end

def parse_fields(block)
  fields = {}
  index = 0

  while index < block.length
    while index < block.length && block[index] =~ /[\s,]/
      index += 1
    end
    break if index >= block.length

    name_start = index
    while index < block.length && block[index] =~ /[A-Za-z0-9_:-]/
      index += 1
    end
    field_name = block[name_start...index].to_s.downcase
    break if field_name.empty?

    while index < block.length && block[index] =~ /\s/
      index += 1
    end
    break unless block[index] == "="

    index += 1
    while index < block.length && block[index] =~ /\s/
      index += 1
    end
    break if index >= block.length

    value = ""
    if block[index] == "{"
      depth = 0
      start = index
      while index < block.length
        char = block[index]
        depth += 1 if char == "{"
        depth -= 1 if char == "}"
        index += 1
        break if depth.zero?
      end
      value = block[start...index]
    elsif block[index] == "\""
      start = index
      index += 1
      while index < block.length
        if block[index] == "\"" && block[index - 1] != "\\"
          index += 1
          break
        end
        index += 1
      end
      value = block[start...index]
    else
      start = index
      while index < block.length && block[index] != ","
        index += 1
      end
      value = block[start...index]
    end

    fields[field_name] = clean_value(value)
  end

  fields
end

def parse_bibtex(content)
  entries = []
  i = 0

  while i < content.length
    at = content.index("@", i)
    break unless at

    type_start = at + 1
    type_end = type_start
    type_end += 1 while type_end < content.length && content[type_end] =~ /[A-Za-z]/
    entry_type = content[type_start...type_end].to_s.downcase

    while type_end < content.length && content[type_end] =~ /\s/
      type_end += 1
    end
    break unless ["{", "("].include?(content[type_end])

    open_char = content[type_end]
    close_char = open_char == "{" ? "}" : ")"
    depth = 1
    cursor = type_end + 1
    while cursor < content.length && depth.positive?
      depth += 1 if content[cursor] == open_char
      depth -= 1 if content[cursor] == close_char
      cursor += 1
    end

    body = content[(type_end + 1)...(cursor - 1)].to_s.strip
    comma_index = body.index(",")
    if comma_index
      key = body[0...comma_index].to_s.strip
      fields_block = body[(comma_index + 1)..].to_s
      entries << {
        "type" => entry_type,
        "key" => key,
        "fields" => parse_fields(fields_block)
      }
    end

    i = cursor
  end

  entries
end

def canonical_entry_type(entry_type)
  text = entry_type.to_s.downcase.strip
  return "misc" if text.empty?

  ENTRY_TYPE_ALIAS[text] || "misc"
end

def compact_segments(*values)
  values.flatten.map { |v| clean_value(v) }.reject(&:empty?)
end

def format_volume_number_pages(fields)
  volume = clean_value(fields["volume"])
  issue = clean_value(fields["number"])
  pages = clean_value(fields["pages"])

  segments = []
  segments << "vol. #{volume}" unless volume.empty?
  segments << "no. #{issue}" unless issue.empty?
  segments << "pp. #{pages}" unless pages.empty?
  segments.join(", ")
end

def thesis_label(entry_type)
  case entry_type
  when "phdthesis"
    "PhD thesis"
  when "mastersthesis"
    "Master's thesis"
  else
    "Thesis"
  end
end

def ieee_base(entry)
  fields = entry["fields"]
  entry_type = canonical_entry_type(entry["type"])
  authors_raw = clean_value(fields["author"])
  editors_raw = clean_value(fields["editor"])
  authors = authors_raw.empty? ? "" : format_authors_ieee(fields["author"])
  editors = editors_raw.empty? ? "" : format_authors_ieee(fields["editor"])
  title = clean_value(fields["title"])
  year = entry_year(fields)
  publisher = clean_value(fields["publisher"])
  institution = clean_value(fields["institution"])
  school = clean_value(fields["school"])
  organization = clean_value(fields["organization"])
  journal = clean_value(fields["journal"])
  booktitle = clean_value(fields["booktitle"])
  howpublished = clean_value(fields["howpublished"])
  report_number = clean_value(fields["number"])
  note = clean_value(fields["note"])
  edition = clean_value(fields["edition"])
  venue_details = format_volume_number_pages(fields)
  principal_names = authors.empty? ? editors : authors

  segments = []
  case entry_type
  when "article"
    segments += compact_segments(principal_names, title.empty? ? "" : "\"#{title}\"", journal, venue_details, year)
  when "book"
    segments += compact_segments(principal_names, title, edition.empty? ? "" : "#{edition} ed.", publisher, year)
  when "inproceedings", "incollection"
    in_label = booktitle.empty? ? "" : "in #{booktitle}"
    segments += compact_segments(principal_names, title.empty? ? "" : "\"#{title}\"", in_label, venue_details, publisher, organization, year)
  when "proceedings"
    segments += compact_segments(principal_names, title, publisher, organization, year)
  when "techreport"
    report_label = report_number.empty? ? "" : "Tech. Rep. #{report_number}"
    segments += compact_segments(principal_names, title.empty? ? "" : "\"#{title}\"", institution, report_label, year)
  when "phdthesis", "mastersthesis"
    segments += compact_segments(principal_names, title.empty? ? "" : "\"#{title}\"", thesis_label(entry_type), school, year)
  else
    venue = journal
    venue = booktitle if venue.empty?
    venue = publisher if venue.empty?
    venue = institution if venue.empty?
    venue = organization if venue.empty?
    venue = howpublished if venue.empty?
    segments += compact_segments(principal_names, title.empty? ? "" : "\"#{title}\"", venue, year)
  end

  segments << note unless note.empty?
  text = segments.join(", ")
  text += "." unless text.end_with?(".")
  text
end

def harvard_base(entry)
  fields = entry["fields"]
  entry_type = canonical_entry_type(entry["type"])
  authors_raw = clean_value(fields["author"])
  editors_raw = clean_value(fields["editor"])
  authors = authors_raw.empty? ? "" : format_authors_harvard(fields["author"])
  editors = editors_raw.empty? ? "" : format_authors_harvard(fields["editor"])
  title = clean_value(fields["title"])
  year = entry_year(fields)
  publisher = clean_value(fields["publisher"])
  institution = clean_value(fields["institution"])
  school = clean_value(fields["school"])
  organization = clean_value(fields["organization"])
  journal = clean_value(fields["journal"])
  booktitle = clean_value(fields["booktitle"])
  howpublished = clean_value(fields["howpublished"])
  report_number = clean_value(fields["number"])
  note = clean_value(fields["note"])
  edition = clean_value(fields["edition"])
  venue_details = format_volume_number_pages(fields)
  principal_names = authors.empty? ? editors : authors

  parts = []
  parts << principal_names.sub(/\.$/, '') unless principal_names.empty?
  parts << "(#{year})" unless year.empty?

  case entry_type
  when "article"
    parts += compact_segments(title, journal, venue_details)
  when "book"
    book_edition = edition.empty? ? "" : "#{edition} ed"
    parts += compact_segments(title, book_edition, publisher)
  when "inproceedings", "incollection"
    in_label = booktitle.empty? ? "" : "In #{booktitle}"
    parts += compact_segments(title, in_label, venue_details, publisher, organization)
  when "proceedings"
    parts += compact_segments(title, publisher, organization)
  when "techreport"
    report_label = report_number.empty? ? "" : "Tech. Rep. #{report_number}"
    parts += compact_segments(title, institution, report_label)
  when "phdthesis", "mastersthesis"
    parts += compact_segments(title, thesis_label(entry_type), school)
  else
    venue = journal
    venue = booktitle if venue.empty?
    venue = publisher if venue.empty?
    venue = institution if venue.empty?
    venue = organization if venue.empty?
    venue = howpublished if venue.empty?
    parts += compact_segments(title, venue)
  end

  parts << note unless note.empty?
  text = parts.join(". ")
  text += "." unless text.end_with?(".")
  text
end

def normalize_entry(entry)
  fields = entry["fields"]
  entry_type = canonical_entry_type(entry["type"])
  authors = split_authors(fields["author"])
  short_author = clean_value(fields["shortauthor"])
  short_author = short_author_from(authors) if short_author.empty?

  url = clean_value(fields["url"])
  doi = clean_value(fields["doi"])
  arxiv = clean_value(fields["eprint"])
  arxiv = clean_value(fields["arxiv"]) if arxiv.empty?
  arxiv = clean_value(fields["archiveprefix"]) == "arXiv" ? clean_value(fields["eprint"]) : arxiv

  published_iso = parse_iso_date(fields["date"])
  accessed_iso = parse_iso_date(fields["urldate"])

  normalized = {
    "entry_type" => entry_type,
    "short_author" => short_author,
    "year" => entry_year(fields),
    "authors" => clean_value(fields["author"]),
    "editor" => clean_value(fields["editor"]),
    "title" => clean_value(fields["title"]),
    "journal" => clean_value(fields["journal"]),
    "book" => clean_value(fields["booktitle"]),
    "publisher" => clean_value(fields["publisher"]),
    "institution" => clean_value(fields["institution"]),
    "school" => clean_value(fields["school"]),
    "organization" => clean_value(fields["organization"]),
    "edition" => clean_value(fields["edition"]),
    "volume" => clean_value(fields["volume"]),
    "number" => clean_value(fields["number"]),
    "pages" => clean_value(fields["pages"]),
    "howpublished" => clean_value(fields["howpublished"]),
    "url" => url,
    "doi" => doi,
    "arxiv" => arxiv,
    "published_iso" => published_iso,
    "accessed_iso" => accessed_iso,
    "published_date" => format_human_date(published_iso),
    "accessed_date" => format_human_date(accessed_iso),
    "ieee_base" => ieee_base(entry),
    "harvard_base" => harvard_base(entry)
  }

  note = clean_value(fields["note"])
  unless note.empty? || note.start_with?("Legacy YAML citation preserved:")
    normalized["note"] = note
  end

  normalized.delete_if { |_k, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
  normalized
end

def normalize_legacy_entry(entry)
  legacy = (entry || {}).dup
  ieee_text = clean_value(legacy["ieee"])
  harvard_text = clean_value(legacy["harvard"])

  extracted_url = extract_url_from_text(ieee_text)
  extracted_url = extract_url_from_text(harvard_text) if extracted_url.nil? || extracted_url.empty?

  accessed_date = parse_accessed_date_from_text(ieee_text)
  accessed_date = parse_accessed_date_from_text(harvard_text) unless accessed_date

  if accessed_date
    legacy["accessed_iso"] ||= accessed_date.strftime("%Y-%m-%d")
    legacy["accessed_date"] ||= accessed_date.strftime("%-d %B %Y")
  end

  legacy["url"] ||= extracted_url unless extracted_url.nil? || extracted_url.empty?
  legacy["source_format"] = "legacy-yaml"
  legacy.delete_if { |_k, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
  legacy
end

unless File.exist?(BIB_FILE)
  warn "Missing BibTeX source: #{BIB_FILE}"
  exit 1
end

bib_content = File.read(BIB_FILE)
entries = parse_bibtex(bib_content)
generated = {}

entries.each do |entry|
  key = entry["key"]
  next if key.nil? || key.empty?

  generated[key] = normalize_entry(entry)
  generated[key]["source_format"] = "bibtex"
end

File.write(OUTPUT_FILE, generated.to_yaml(line_width: -1))
puts "Generated #{OUTPUT_FILE} with #{generated.length} BibTeX entries"