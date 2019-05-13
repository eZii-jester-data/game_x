require 'zircon'
require 'colorize'

client = Zircon.new(
  server: 'irc.twitch.tv',
  port: '6667',
  channel: '#lemonandroid',
  username: 'lemonandroid',
  password: ENV["TWITCH_OAUTH_TOKEN"]
)

removed_colors = [:black, :white, :light_black, :light_white]
colors = String.colors - removed_colors

f = File.open('chat.txt', 'w')

client.on_message do |message|
  puts ">>> #{message.from}: #{message.body}".colorize(colors.sample)
  f.write(message.body.to_s + "\n")

 if message.body.to_s =~ /hack/
	`cliclick m:100,100`
 end

 if message.body.to_s =~ /open gam/
	`ruby /Users/lemonandroid/one/game/ruby/runnable.rb &`
 end

 if message.body.to_s =~ /bundle install/
	`cd /Users/lemonandroid/one/game/ruby && bundle install &`
 end

 if message.body.to_s =~ /move plane/
  `
    osascript -e 'tell application "System Events"
      key down "a"
      delay 1
      key up "a"
    end tell'
  `
 end

 if message.body.to_s =~ /key press (\w)/
  puts $1

  keypress = """
    osascript -e 'tell application \"System Events\"
      key down \"#{$1}\"
      delay 1
      key up \"#{$1}\"
    end tell'
  """

  puts keypress

  `#{keypress}`
 end

end

client.run!
f.close
