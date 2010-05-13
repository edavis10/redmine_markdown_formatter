require 'rdiscount'

module RedmineMarkdownFormatter
  class WikiFormatter
    TOC_REGEX = /<p>\{\{([<>]?)toc\}\}<\/p>/i
    
    def initialize(text)
      @text = text
    end

    def to_html(&block)
      content = RDiscount.new(@text, :smart, :generate_toc)
      html = inline_toc(@text, content.to_html)
      html.gsub(/<a\s/, "<a class='external'") # Add the `external` class to every link
      html
    rescue => e
      return("<pre>problem parsing wiki text: #{e.message}\n"+
             "original text: \n"+
             @text+
             "</pre>")
    end

    # Tried to use rDiscount's toc_content but:
    # 1. it produces invalid HTML with deep nests
    # 2. Redmine's css assumes a single ul list
    def inline_toc(source_text, html)
      html.gsub(TOC_REGEX) do
        div_class = 'toc'
        div_class << ' right' if $1 == '>'
        div_class << ' left' if $1 == '<'
        out = "<ul class=\"#{div_class}\">"

        source_text.scan(/[^\\]#.*/).each do |heading|
          # 1+ '#'s followed by a few words/spaces/hyphens with some
          # optional '#'s
          _,
          heading_markers,
          heading_content,
          _ = heading.match(/(#+)([^#]*)(#*)/).to_a

          level = heading_markers.length

          # replaces non word caracters by +, excluding some allowed characters
          #
          # - . ( ) | / : ; ' " { } ? [ ] \ $
          #
          #  (Markdown uses + instead of -)
          content = heading_content.strip
          anchor = content.gsub(%r{[^\w\s\-\.\(\)\|\/:;\'\"\{\}\?\[\]\\\$]}, '').gsub(%r{\s+(\-+\s*)?}, '+')

          out << "<li class=\"heading#{level}\"><a href=\"##{anchor}\">#{content}</a></li>\n"
        end
        out << '</ul>'
        out
      end
    end


  end
end
