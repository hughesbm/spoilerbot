require 'dotenv/load'
require 'sinatra/base'
require 'sinatra/activerecord'
require './config/slack'
require './models/spoiler'

class SpoilerBot < Sinatra::Application
  client = Slack::Web::Client.new

  client.auth_test

  post '/slack/spoilerbot/post' do
    halt 403 unless request_authentic?(params[:token])

    spoiler = Spoiler.create(
      author: params[:user_name],
      channel_id: params[:channel_id],
      team_domain: params[:team_domain],
      text: params[:text]
    )

    client.chat_postMessage(
      channel: spoiler.channel_id,
      text: spoiler.safe_text,
      attachments: spoiler.attachment_safe
    )

    halt 200
  end

  post '/slack/spoilerbot/show' do
    payload = JSON.parse(params['payload'], symbolize_names: true)

    halt 403 unless request_authentic?(payload[:token])

    message_ts = payload[:message_ts]
    spoiler_id = payload[:callback_id]
    user_id = payload[:user][:id]

    spoiler = Spoiler.find(spoiler_id)

    client.chat_postMessage(
      channel: user_id,
      text: spoiler.spoiler_text,
      attachments: spoiler.attachment_spoiler(message_ts)
    )

    halt 200
  end

  private

  def request_authentic?(token)
    token == ENV['SLACK_VERIFICATION_TOKEN']
  end
end
