class Spoiler
  attr_reader :channel_id, :team_domain, :text, :timestamp, :user_name

  def initialize(params)
    @channel_id = params[:channel_id]
    @team_domain = params[:team_domain]
    @text = params[:text]
    @timestamp = params[:timestamp]
    @user_name = params[:user_name]
  end

  SAFE_PATTERN = /(?<=\[)([\s\S]*?)(?=\])/
  SPOILER_PATTERN = /([\s\S]*?)(?=\s\[)/

  def safe_text
    text[SAFE_PATTERN]
  end

  def spoiler_text
    text =~ SAFE_PATTERN ? text[SPOILER_PATTERN] : text
  end
end
