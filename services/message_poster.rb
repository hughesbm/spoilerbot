class MessagePoster
  attr_reader :client, :archive_channel

  def initialize(client, archive_channel)
    @client = client
    @archive_channel = archive_channel
  end

  def post_reference(spoiler)
    post(archive_channel, attachment_reference(spoiler))
  end

  def post_safe(spoiler, reference_timestamp)
    post(spoiler.channel_id, attachment_safe(spoiler, reference_timestamp))
  end

  def post_spoiler(spoiler, message_timestamp)
    post(spoiler.channel_id, attachment_spoiler(spoiler, message_timestamp))
  end

  private

  def post(channel, attachments)
    client.chat_postMessage(
      channel: channel,
      attachments: attachments,
      as_user: true
    )
  end

  def attachment_reference(spoiler)
    [
      {
        "fallback": spoiler.text,
        "callback_id": 'spoiler_reference',
        "fields": [
          {
            "title": "channel_id",
            "value": spoiler.channel_id
          },
          {
            "title": "team_domain",
            "value": spoiler.team_domain
          },
          {
            "title": "text",
            "value": spoiler.text
          },
          {
            "title": "user_name",
            "value": spoiler.user_name
          }
        ],
      }
    ]
  end

  def attachment_safe(spoiler, timestamp)
    [
      {
        "fallback": spoiler.safe_text,
        "callback_id": timestamp,
        "text": spoiler.safe_text,
        "actions": [
          {
            "name": "show_spoiler",
            "text": "Spoil me!",
            "style": "primary",
            "type": "button",
            "value": "show"
          }
        ],
        "footer": "Posted by #{spoiler.user_name}"
      }
    ]
  end

  def attachment_spoiler(spoiler, timestamp)
    [
      {
        "fallback": spoiler.spoiler_text,
        "callback_id": 'spoiler_text',
        "text": spoiler.spoiler_text,
        "footer": "Posted by #{spoiler.user_name} (<#{message_link(spoiler, timestamp)}|Original Post>)",
        "ts": timestamp
      }
    ]
  end

  def message_link(spoiler, timestamp)
    url_timestamp = timestamp.tr('.', '')

    "https://#{spoiler.team_domain}.slack.com/archives/#{spoiler.channel_id}/p#{url_timestamp}"
  end
end
