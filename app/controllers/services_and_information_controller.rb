class ServicesAndInformationController < ApplicationController
  def index
    base_path = "/government/organisations/#{params[:organisation_id]}/services-information"
    content_item = Services.content_store.content_item!(base_path).to_hash
    links_grouper = ServicesAndInformationLinksGrouper.new(params[:organisation_id])
    @navigation_helpers = GovukNavigationHelpers::NavigationHelper.new(content_item)
    @organisation = content_item.dig("links", "parent", 0)
    @grouped_links = links_grouper.parsed_grouped_links
    set_slimmer_analytics_headers
  end

private

  def set_slimmer_analytics_headers
    set_slimmer_headers(organisations: "<#{@organisation['analytics_identifier']}>")
  end
end
