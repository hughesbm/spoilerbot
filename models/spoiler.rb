class Spoiler < ActiveRecord::Base
  SAFE_PATTERN = /(?<=\[)([\s\S]*?)(?=\])/
  SPOILER_PATTERN = /([\s\S]*?)(?=\s\[)/

  def attachment_safe
    [
      {
        "fallback": safe_text,
        "callback_id": id,
        "attachment_type": "default",
        "text": safe_text,
        "actions": [
          {
            "name": "show_spoiler",
            "text": "Spoil me!",
            "style": "primary",
            "type": "button",
            "value": "show"
          }
        ],
        "footer": "Posted by #{author}"
      }
    ]
  end

  def attachment_spoiler(message_ts)
    [
      {
        "fallback": spoiler_text,
        "callback_id": id,
        "text": spoiler_text,
        "footer": "Posted by #{author} (<#{message_link(message_ts)}|Original Post>)",
        "ts": message_ts
      }
    ]
  end

  def message_link(message_ts)
    ts = message_ts.tr('.', '')

    "https://#{team_domain}.slack.com/archives/#{channel_id}/p#{ts}"
  end

  def safe_text
    text[SAFE_PATTERN]
  end

  def spoiler_text
    text.match?(SAFE_PATTERN) ? text[SPOILER_PATTERN] : text
  end
end
