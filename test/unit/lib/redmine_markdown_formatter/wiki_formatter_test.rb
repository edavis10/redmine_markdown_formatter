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

  end

  private
  
  def assert_html_output(input, output)
    assert_equal "<p>#{output}</p>\n", @formatter.new(input).to_html, "Formatting the following text failed:\n===\n#{input}\n===\n"
  end
end
