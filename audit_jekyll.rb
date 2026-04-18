require 'yaml'

patterns = [
  'docs/_posts/*.md',
  'docs/*.md',
  'docs/legal/**/*.md',
  'docs/legal/*.md'
]

files = patterns.flat_map { |p| Dir.glob(File.join('..', p)) }.uniq

perm_map = {}
slug_map = {}
anomalies = []

files.each do |file|
  next unless File.file?(file)
  content = File.read(file, encoding: 'UTF-8')
  begin
    if content =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
      front_matter = YAML.safe_load($1)
    else
      front_matter = {}
    end
  rescue => e
    anomalies << "#{file}: YAML Error: #{e.message}"
    next
  end

  title = front_matter['title']
  permalink = front_matter['permalink']
  
  raw_slug = front_matter['slug'] || (permalink ? permalink.split('/').last : nil)
  if raw_slug.nil? && file.include?('_posts/')
    raw_slug = File.basename(file, '.md').sub(/\A\d{4}-\d{2}-\d{2}-/, '')
  end
  slug = raw_slug

  is_index = file.end_with?('index.html') || file.end_with?('index.md')

  anomalies << "#{file}: Missing title" if (title.nil? || title.to_s.empty?) && !is_index
  anomalies << "#{file}: Missing permalink" if (permalink.nil? || permalink.to_s.empty?) && !is_index

  if permalink
    if permalink =~ /[A-Z]/
       anomalies << "#{file}: Permalink contains uppercase: #{permalink}"
    end
    if permalink =~ /_/
       anomalies << "#{file}: Permalink contains underscores: #{permalink}"
    end
    if permalink =~ /\s/
       anomalies << "#{file}: Permalink contains spaces: #{permalink}"
    end
    (perm_map[permalink] ||= []) << file
  end

  if slug
    if slug =~ /[A-Z]/
       anomalies << "#{file}: Slug contains uppercase: #{slug}"
    end
    if slug =~ /\s/
       anomalies << "#{file}: Slug contains spaces: #{slug}"
    end
    if slug.length > 90
       anomalies << "#{file}: Slug overly long (>90): #{slug.length} characters (#{slug})"
    end
    (slug_map[slug] ||= []) << file
  end
end

perm_map.each do |perm, paths|
  if paths.size > 1
    anomalies << "Duplicate permalink '#{perm}': #{paths.join(', ')}"
  end
end

slug_map.each do |slug, paths|
  if paths.size > 1
    anomalies << "Duplicate slug '#{slug}': #{paths.join(', ')}"
  end
end

all_anomalies = anomalies.uniq
if all_anomalies.empty?
  puts "PASS: No anomalies found in #{files.size} files."
else
  puts "Audit found #{all_anomalies.size} issues in #{files.size} files:"
  puts all_anomalies.join("\n")
end
