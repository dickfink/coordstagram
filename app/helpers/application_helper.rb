module ApplicationHelper
  include Twitter::Autolink

  def mobile_device?
    request.user_agent =~ /Mobile|webOS/
  end

  def name_of_site
    ENV.fetch('NAME_OF_SITE', 'Coordstagram')
  end

  def page_header_subtitle
    anchor_text = %{
      <span class="glyphicon glyphicon-map-marker"></span>#{InstagramItem::LATITUDE}, #{InstagramItem::LONGITUDE}
    }.html_safe

    %{
      Instagrams taken within #{pluralize InstagramItem::MAX_DISTANCE_IN_METERS.to_i, 'meter'} of #{link_to anchor_text, '#', title: 'view map', class: 'map-link', 'data-toggle': 'modal', 'data-target': '#map-modal'}
    }.html_safe
  end

  def title_for(item)
    type = item.image? ? 'photo' : item.instagram_type
    "Instagram #{type} by #{item.full_data.user.full_name}"
  end

  def description_for(item)
    text = item.caption_text_with_extra_tags.to_s

    desc = "#{item.full_data.user.full_name} on Instagram"
    desc << ": #{text.first(130)}" if text.present?
    desc << "…" if text.length > 130

    desc
  end

  def meta_tags_for_index
    description_text = "Instagram photos and videos taken near the coordinates #{InstagramItem::CENTER_COORDINATES.join(', ')}"

    %{
      <link rel="canonical" href="#{root_url}"/>
      <meta name="description" content="#{description_text}"/>
      <meta property="og:title" content="#{description_text}"/>
      <meta property="og:url" content="#{root_url}"/>
      <meta property="og:site_name" content="#{name_of_site}"/>
    }.html_safe
  end

  def meta_tags_for(item)
    canonical_url = item_permalink_url(:path => item.path.sub(/^\/+/, ''))
    img_url = item.full_data.images.standard_resolution.url

    %{
      <link rel="canonical" href="#{canonical_url}"/>
      <meta name="description" content="#{description_for(item)}"/>
      <meta property="og:type" content="article"/>
      <meta property="og:title" content="#{description_for(item)}"/>
      <meta property="og:url" content="#{canonical_url}"/>
      <meta property="og:image" content="#{img_url}"/>
      <meta property="og:site_name" content="#{name_of_site}"/>
      <meta name="twitter:card" content="summary_large_image"/>
      <meta name="twitter:title" content="#{title_for(item)}"/>
      <meta name="twitter:description" content="#{description_for(item)}"/>
      <meta name="twitter:image:src" content="#{img_url}"/>
    }.html_safe
  end

  def google_analytics
    return unless Rails.env.production? && ENV['GOOGLE_ANALYTICS_TRACKING_ID']

    %{
      <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

        ga('create', '#{ENV['GOOGLE_ANALYTICS_TRACKING_ID']}', 'auto');
        ga('send', 'pageview');

      </script>
    }.html_safe
  end

  def autolink_hashtags_and_users(text)
    auto_link(text.to_s, hashtag_url_base: 'http://websta.me/tag/',
                         username_url_base: 'http://instagram.com/',
                         url_class: nil,
                         hashtag_class: nil,
                         username_class: nil,
                         username_include_symbol: true,
                         target_blank: true)
  end

  def formatted_and_linked_caption(item)
    simple_format(autolink_hashtags_and_users(item.caption_text_with_extra_tags))
  end
end