require "integration_test_helper"

class PersonTest < ActionDispatch::IntegrationTest
  before do
    name = "Rufus Scrimgeour"
    slug = "rufus-scrimgeour"
    base_path = "/government/people/#{slug}"

    stub_person_page_content_item(base_path, name)
    stub_person_page_search_query(slug)

    visit base_path
  end

  it "displays the person page" do
    assert_equal page.title, "Rufus Scrimgeour - GOV.UK"
  end

  it "shows schema.org Person structured data" do
    schema_sections = page.find_all("script[type='application/ld+json']", visible: false)
    schemas = schema_sections.map { |section| JSON.parse(section.text(:all)) }

    person_schema = schemas.detect { |schema| schema["@type"] == "Person" }
    assert_equal person_schema["name"], "Rufus Scrimgeour"
  end

  def stub_person_page_content_item(base_path, name)
    content_item = GovukSchemas::RandomExample.for_schema(frontend_schema: "person").merge(
      "title" => name,
      "base_path" => base_path,
    )

    stub_content_store_has_item(base_path, content_item)
  end

  def stub_person_page_search_query(slug)
    stub_request(:get, "https://search.test.gov.uk/search.json")
      .with(query: {
        count: 10,
        fields: %w[content_store_document_type link public_timestamp title],
        filter_people: slug,
        order: "-public_timestamp",
        reject_content_purpose_supergroup: "other",
      })
      .to_return(body: { results: [] }.to_json)
  end
end
