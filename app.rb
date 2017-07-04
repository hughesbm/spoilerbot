require 'dotenv/load'
require 'sinatra/base'
require './config/slack'
require './models/spoiler'
require './services/message_poster'

class SpoilerBot < Sinatra::Application
  client = Slack::Web::Client.new
  client.auth_test
  message_poster = MessagePoster.new(client)

  post '/slack/spoilerbot/post' do
    halt 403 unless request_authentic?(params[:token], params[:team_domain])

    if params[:text] == 'help'
      halt 200, {'Content-Type' => 'application/json'}, message_poster.help
    else
      spoiler = Spoiler.new(params)
      message_poster.post(spoiler, 'safe')

      halt 200
    end
  end

  post '/slack/spoilerbot/show' do
    payload = JSON.parse(params['payload'], symbolize_names: true)

    halt 403 unless request_authentic?(payload[:token], payload[:team][:domain])

    spoiler_params = {
      channel_id: payload[:channel][:id],
      team_domain: payload[:team][:domain],
      text: payload[:callback_id],
      timestamp: payload[:message_ts],
      user_name: payload[:original_message][:attachments][0][:footer].split(' ').last
    }

    spoiler = Spoiler.new(spoiler_params)
    message_poster.post(spoiler, 'spoiler')

    halt 200
  end

  private

  def request_authentic?(token, team_domain)
    token == ENV['SLACK_VERIFICATION_TOKEN'] &&
      team_domain == ENV['TEAM_DOMAIN']
  end
end
