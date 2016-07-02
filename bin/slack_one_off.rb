require 'httmultiparty'

class SlackcatOneOff
  include HTTMultiParty
  base_uri 'https://slack.com/api'

  def initialize(token)
    @token = token
  end
  
  def search_for(term, fdate=Time.now.strftime('%Y-%m-%d'), channels='engineering')
    method = 'search.messages'
    entries = []
    cnt = 0
    max_cnt = 15

    a_channels = channels.strip.split(/\s*,\s*/)

    a_channels.each do |channel|

      query = "in:#{channel} from:me on:#{fdate} #{term}"
      entries.concat([{query: query}])
      #raise "Searching for #{query}"

      matches = self.class.get("/#{method}", query: { token: @token, query: query }).tap do |response|
        raise "error searching for #{query} from #{method}: #{response.fetch('error', 'unknown error')}" unless response['ok']
      end.fetch("messages").fetch("matches")

      entries.concat matches.map{|x| 
        #printf "."
        x['ts'] = DateTime.strptime(x['ts'],'%s').to_time
        {ts: x['ts'], permalink: x['permalink'], text: x['text'], channel: channel}
      }
    end
    entries
  end
end

unless ENV.has_key?('SLACK_TOKEN')
  # puts ">1>"
  if File.exists?(File.expand_path('~/.slackcat'))
    # puts ">2>"
    ENV['SLACK_TOKEN'] = IO.read(File.expand_path('~/.slackcat')).chomp; nil
    # puts ">3>: #{ENV['SLACK_TOKEN']}"
  end
end

#raise ARGV.inspect
raise "Usage: ruby '/Users/davidvezzani/reliacode/crystal_commerce/slackcat/bin/slack_one_off.rb' 'brb'" unless(ARGV.length > 0)
resp = SlackcatOneOff.new(ENV['SLACK_TOKEN']).search_for(*ARGV)
puts resp.to_json
