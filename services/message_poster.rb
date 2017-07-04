class MessagePoster
  attr_reader :client

  def initialize(client)
    @client = client
  end

  def help
    {
      "response_type": "ephemeral",
      "attachments": [
        {
          "fallback": "SpoilerBot help",
          "title": "SpoilerBot Help",
          "text": "To post a spoiler, type \"/spoilerbot\", followed by the text you wish to hide. You may also add a preview message by enclosing it in [square brackets] after your spoiler text.",
          "fields": [
            {
              "title": "Example",
              "value": "/spoilerbot Darth Vader [Guess who Luke Skywalker's father is?]"
            },
            {
              "title": "Please Note",
              "value": "Spoiler text is limited to 255 characters. If you exceed this limit, your message will be truncated."
            }
          ]
        }
      ]
    }.to_json
  end

  def post(spoiler, type)
    client.chat_postMessage(
      channel: spoiler.channel_id,
      attachments: send(('attachment_'+type).to_sym, spoiler)
    )
  end

  private

  def attachment_safe(spoiler)
    [
      {
        "fallback": spoiler.safe_text,
        "callback_id": spoiler.spoiler_text,
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

  def attachment_spoiler(spoiler)
    [
      {
        "fallback": spoiler.text,
        "callback_id": 'spoiler_text',
        "text": spoiler.text,
        "footer": "Posted by #{spoiler.user_name} (<#{message_link(spoiler)}|Original Post>)",
        "ts": spoiler.timestamp
      }
    ]
  end

  def message_link(spoiler)
    url_timestamp = spoiler.timestamp.tr('.', '')

    "https://#{spoiler.team_domain}.slack.com/archives/#{spoiler.channel_id}/p#{url_timestamp}"
  end
end
