class RecordLookup
  attr_reader :client, :archive_channel

  def initialize(client, archive_channel)
    @client = client
    @archive_channel = archive_channel
  end

  def timestamp_from_spoiler(spoiler)
    record_from_spoiler(spoiler)[:ts]
  end

  def spoiler_from_timestamp(timestamp)
    parameters = {}

    record_from_timestamp(timestamp)[:attachments][0][:fields].each do |field|
      parameters[field[:title].to_sym] = field[:value]
    end

    Spoiler.new(parameters)
  end

  private

  def history(search_time)
    client.groups_history(
      channel: archive_channel,
      oldest: search_time,
      inclusive: true
    )
  end

  def record_from_spoiler(spoiler)
    one_second_ago = Time.now.to_i - 1

    history(one_second_ago)[:messages].find do |message|
      message[:attachments][0][:fields].all? do |field|
        spoiler.public_send(field[:title]) == field[:value]
      end
    end
  end

  def record_from_timestamp(timestamp)
    history(timestamp)[:messages].find do |message|
      message[:ts] == timestamp
    end
  end
end
