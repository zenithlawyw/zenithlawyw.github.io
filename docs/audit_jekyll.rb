require 'yaml'
require 'set'

files = Dir.glob('docs/_posts/*.md') + Dir.glob('docs/*.md') + Dir.glob('docs/legal/**/*.md')
permalinks = {}
slugs = {}
anomalies = []

files.each do |file|
  begin
    content = File.read(file)
    if content =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
      frontmatter = YAML.safe_load($1)
    else
      next # Skip files without frontmatter
    end
    
    title = frontmatter['title']
    permalink = frontmatter['permalink']
    # Infer slug from filename if not explicit. 
    # Jekyll standard: YYYY-MM-DD-title.md or title.md
    slug = frontmatter['slug'] || File.basename(file, '.md').gsub(/^\d{4}-\d{2}-\d{2}-/, '')

    # Checks
    anomalies << "#{file}: Missing title" if title.nil? || title.to_s.empty?
    anomalies << "#{file}: Missing permalink" if permalink.nil? || permalink.to_s.empty?
    
    if permalink
      if permalinks[permalink]
        anomalies << "#{file}: Duplicate permalink '#{permalink}' (also in #{permalinks[permalink]})"
      else
        permalinks[permalink] = file
      end
      
      if permalink =~ /[A-Z\s]/
        anomalies << "#{file}: Uppercase or spaces in permalink '#{permalink}'"
      end
    end

    if slug
      if slugs[slug]
        anomalies << "#{file}: Duplicate slug '#{slug}' (also in #{slugs[slug]})"
      else
        slugs[slug] = file
      end

      if slug =~ /[A-Z\s]/
        anomalies << "#{file}: Uppercase or spaces in slug '#{slug}'"
      end

      if slug.length > 90
        anomalies << "#{file}: Slug too long (#{slug.length} chars)"
      end

      if slug !~ /\A[a-z0-0\-]+\z/
        anomalies << "#{file}: Non-hyphen-safe slug '#{slug}'"
      end
    end

  rescue => e
    anomalies << "#{file}: Error parsing: #{e.message}"
  end
end

if anomalies.empty?
  puts "PASS: No anomalies found."
else
  puts "FAIL: Anomalies detected:"
  puts anomalies.join("\n")
end
