require 'dotenv/load'
require 'sinatra/base'
require './config/slack'
require './models/spoiler'
require './services/message_poster'
require './services/record_lookup'

class SpoilerBot < Sinatra::Application
  api_client = Slack::Web::Client.new
  bot_client = Slack::Web::Client.new(token: ENV['SLACK_BOT_TOKEN'])

  api_client.auth_test
  bot_id = bot_client.auth_test[:user_id]

  bot_group = bot_client.groups_list[:groups].find do |group|
    group[:name] == 'spoilerbot_archive'
  end

  if bot_group.nil? || bot_group[:is_archived]
    if bot_group.nil?
      group_id = api_client.groups_create(name: 'spoilerbot_archive')[:group][:id]
    else
      group_id = api_client.groups_unarchive(channel: bot_group[:id])
    end

    api_client.groups_invite(channel: group_id, user: bot_id)

    ARCHIVE_CHANNEL = group_id
  else
    ARCHIVE_CHANNEL = bot_group[:id]
  end

  message_poster = MessagePoster.new(bot_client, ARCHIVE_CHANNEL)
  record_lookup = RecordLookup.new(api_client, ARCHIVE_CHANNEL)

  post '/slack/spoilerbot/post' do
    halt 403 unless request_authentic?(params[:token], params[:team_domain])

    spoiler = Spoiler.new(params)
    message_poster.post_reference(spoiler)
    reference_timestamp = record_lookup.timestamp_from_spoiler(spoiler)
    message_poster.post_safe(spoiler, reference_timestamp)

    halt 200
  end

  post '/slack/spoilerbot/show' do
    payload = JSON.parse(params['payload'], symbolize_names: true)

    halt 403 unless request_authentic?(payload[:token], payload[:team][:domain])

    reference_timestamp = payload[:callback_id]
    message_timestamp = payload[:message_ts]

    spoiler = record_lookup.spoiler_from_timestamp(reference_timestamp)
    message_poster.post_spoiler(spoiler, message_timestamp)

    halt 200
  end

  private

  def request_authentic?(token, team_domain)
    token == ENV['SLACK_VERIFICATION_TOKEN'] &&
      team_domain == ENV['TEAM_DOMAIN']
  end
end
