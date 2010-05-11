require File.dirname(__FILE__) + '/../../../test_helper'

class RedmineMarkdownFormatter::WikiFormatterTest < ActiveSupport::TestCase
  include ActionController::Assertions::SelectorAssertions

  # Used by assert_select
  def html_document
    HTML::Document.new(@response.body)
  end
  
  def setup
    super
    @response = ActionController::TestResponse.new
    @formatter = RedmineMarkdownFormatter::WikiFormatter
  end

  context "#to_html" do
    should "convert basic markdown text" do
      assert_html_output('*emphasis* and **bold**',
                         '<em>emphasis</em> and <strong>bold</strong>')
    end

    should "convert links" do
      assert_html_output('[Redmine](http://redmine.org "Redmine PM")',
                         '<a href="http://redmine.org" title="Redmine PM">Redmine</a>')
    end

    should "add a table of contents when requested" do
      source ="{{>toc}}
# Title

## Section

### Sub Section ###

Content

## Section Two
"
      @response.body = @formatter.new(source).to_html

      assert_select 'h1#Title', :text => 'Title'
      assert_select 'h2#Section', :text => 'Section'
      assert_select 'h3', :id => 'Sub+Section', :text => 'Sub Section'
      assert_select 'h2', :id => 'Section+Two', :text => 'Section Two'
      assert_select 'p', :text => 'Content'

      assert_select 'ul.toc.right' do
        assert_select 'li.heading1 a', :text => /Title/
        assert_select 'li.heading2 a', :text => /Section/
        assert_select 'li.heading3 a', :text => /Sub Section/
        assert_select 'li.heading2 a', :text => /Section Two/
      end
    end
  end

  private
  
  def assert_html_output(input, output)
    assert_equal "<p>#{output}</p>\n", @formatter.new(input).to_html, "Formatting the following text failed:\n===\n#{input}\n===\n"
  end
end
