require 'zircon'
require 'colorize'
require 'byebug'

LOG_FILE = File.open('chat.txt', 'w')
COMMANDS_HELP = <<-TWITCH_CHAT_MESSAGE
  Write "hack" and move the mouse courser to the top left corner of the screen

  move plane

  Move the plane in the 3d gam

  key press (a-z,0-9) i.e. "key press m"

  Press any letter or number key

  open gam

  Open the 3d cad-like gam

  bundle install

  Update ruby gems for the gam
TWITCH_CHAT_MESSAGE

def start
  client = Zircon.new(
    server: 'irc.twitch.tv',
    port: '6667',
    channel: '#lemonandroid',
    username: 'lemonandroid',
    password: ENV["TWITCH_OAUTH_TOKEN"]
  )

  removed_colors = [:black, :white, :light_black, :light_white]
  colors = String.colors - removed_colors

  client.on_message do |message|
    puts ">>> #{message.from}: #{message.body}".colorize(colors.sample)
    LOG_FILE.write(message.body.to_s + "\n")


    if message.body.to_s =~ /!commands/
      client.privmsg("#lemonandroid", "https://twitter.com/LemonAndroid/status/1128262053880377345")
    end

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

    if message.body.to_s =~ /key press (\w)(?:\s*(\d+)x)?/
      if $2
        `osascript -e 'tell application \"System Events\"
          repeat #{$2} times
            keystroke \"#{$1}\"
          end repeat
        end tell'`
      else
        `osascript -e 'tell application \"System Events\"
          keystroke \"#{$1}\"
        end tell'`
      end
    end
  end

  client.run!
end


def error_catching_restart_loop
  start()
rescue => e
  error_catching_restart_loop()
  LOG_FILE.write(e.message)
end

error_catching_restart_loop()

LOG_FILE.close
