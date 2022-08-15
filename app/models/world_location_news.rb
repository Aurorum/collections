class WorldLocationNews
  attr_reader :content_item

  def initialize(content_item)
    @content_item = content_item
  end

  def self.find!(base_path)
    content_item = ContentItem.find!(base_path)
    new(content_item)
  end

  def title
    @content_item.content_item_data["title"]
  end

  def description
    @content_item.content_item_data["description"]
  end

  def ordered_featured_links
    @content_item.content_item_data.dig("details", "ordered_featured_links")&.map do |link|
      {
        path: link["href"],
        text: link["title"],
      }
    end
  end

  def ordered_featured_documents
    @content_item.content_item_data.dig("details", "ordered_featured_documents")&.map do |document|
      {
        href: document["href"],
        image_src: document.dig("image", "url"),
        image_alt: document.dig("image", "alt_text"),
        heading_text: document["title"],
        description: ActionView::Base.full_sanitizer.sanitize(document["summary"]).truncate(160, separator: " "),
        context: {
          date: document["public_updated_at"]&.to_date,
          text: document["document_type"],
        },
      }
    end
  end

  def mission_statement
    @content_item.content_item_data.dig("details", "mission_statement")
  end

  def translations
    @translations ||= @content_item.content_item_data.dig("links", "available_translations")&.map do |translation|
      {
        locale: translation["locale"],
        base_path: translation["base_path"],
        text: I18n.t("shared.language_name", locale: translation["locale"]),
        active: I18n.locale.to_s == translation["locale"],
      }
    end
  end
end
