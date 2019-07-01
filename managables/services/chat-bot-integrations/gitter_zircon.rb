require 'zircon'
require 'colorize'
require 'byebug'
require 'json'
require 'date'
require 'timeout'


class GitterDumbDevBot
  def initialize
    @currently_selected_project = "lemonandroid/gam"
  end

  def start
    client = Zircon.new(
      server: 'irc.gitter.im',
      port: '6667',
      channel: 'qanda-api/Lobby',
      username: 'LemonAndroid',
      password: ENV["GITTER_IRC_PASSWORD"],
      use_ssl: true
    )

    removed_colors = [:black, :white, :light_black, :light_white]
    colors = String.colors - removed_colors

    client.on_message do |message|
      puts ">>> #{message.from}: #{message.body}".colorize(colors.sample)
      #LOG_FILE.write(message.body.to_s + "\n")

      if message.body.to_s =~ /@LemonAndroid List github repos/i
        client.privmsg("qanda-api/Lobby", "https://api.github.com/users/LemonAndroid/repos")
      end

      if message.body.to_s =~ /List 10 most recently pushed to Github Repos of LemonAndroid/i
        texts = ten_most_pushed_to_github_repos
        texts.each do |text|
          client.privmsg("qanda-api/Lobby", text)
        end
      end

      if message.body.to_s =~ /@LemonAndroid work on (\w+\/\w+)/i
        @currently_selected_project = $1
        client.privmsg("qanda-api/Lobby", whitespace_to_unicode("currently selected project set to #{@currently_selected_project}"))
      end

      if message.body.to_s =~ /@LemonAndroid currently selected project/i
        client.privmsg("qanda-api/Lobby", whitespace_to_unicode("currently selected project is #{@currently_selected_project}"))
      end

      if message.body.to_s =~ /@LemonAndroid show `(.*)`/i
        texts = execute_bash_in_currently_selected_project($1)
        texts.each do |text|
          client.privmsg("qanda-api/Lobby", text)
        end
      end

      if message.body.to_s =~ /@LemonAndroid ls/i
        texts = execute_bash_in_currently_selected_project('ls')
        texts.each do |text|
          client.privmsg("qanda-api/Lobby", text)
        end
      end

      if message.body.to_s =~ /@LemonAndroid cd ([^\s]+)/i
        path = nil
        Dir.chdir(current_repo_dir) do
          path = File.expand_path(File.join('.', Dir.glob("**/#{$1}")))
        end
        texts = execute_bash_in_currently_selected_project("ls #{path}")

        client.privmsg("qanda-api/Lobby", whitespace_to_unicode("Listing directory `#{path}`"))
        texts.each do |text|
          client.privmsg("qanda-api/Lobby", text)
        end
      end

      if message.body.to_s =~ /@LemonAndroid cat ([^\s]+)/i
        path = nil
        Dir.chdir(current_repo_dir) do
          path = File.expand_path(File.join('.', Dir.glob("**/#{$1}")))
        end
        texts = execute_bash_in_currently_selected_project("cat #{path}")

        client.privmsg("qanda-api/Lobby", whitespace_to_unicode("Showing file `#{path}`"))
        texts.each do |text|
          client.privmsg("qanda-api/Lobby", text)
        end
      end
    end

    client.run!
  end
  
  def all_unix_process_ids(unix_id)
    [*(`pgrep -P #{unix_id}`.split("\n")), unix_id]
  end

  def apple_script_window_bounds(unix_pid)
    run_osa_script(
        <<~OSA_SCRIPT
        tell application "System Events" to tell (every process whose unix id is #{unix_pid})
          get {position, size} of every window
        end tell
      OSA_SCRIPT
    )
  end

  def run_osa_script(script)
    `osascript -e '#{script}''`
  end

  def execute_bash_in_currently_selected_project(hopefully_bash_command)
    if currently_selected_project_exists_locally?
      Dir.chdir(current_repo_dir) do
        Bundler.with_clean_env do
          output = `#{hopefully_bash_command}`
          texts_array = whitespace_to_unicode_array(output.split("\n"))
          texts_array + screen_captures_of_visual_processes($?.pid)
        end
      end
    else
      return whitespace_to_unicode_array(
        [
          "Currently selected project (#{@currently_selected_project}) not cloned",
          "Do you want to clone it to the VisualServer with the name \"#{`whoami`.rstrip}\"?"
        ]
      )
    end
  end

  def screen_captures_of_visual_processes(unix_pid)
    return [all_unix_process_ids(unix_pid).inspect]
  end

  def current_repo_dir
    File.expand_path("~/gam-git-repos/#{@currently_selected_project}")
  end

  def currently_selected_project_exists_locally?
    system("stat #{current_repo_dir}")
  end

  def ten_most_pushed_to_github_repos
    output = `curl https://api.github.com/users/LemonAndroid/repos`
    
    processed_output = JSON
    .parse(output)
    .sort_by do |project|
      Date.parse(project["pushed_at"])
    end
    .last(10)
    .map do |project|
      project["full_name"]
    end
    
    whitespace_to_unicode_array(processed_output)
  end

  def whitespace_to_unicode_array(texts)
    texts.map { |text| whitespace_to_unicode(text) }
  end

  def whitespace_to_unicode(text)
    text.gsub(/\s/, "\u2000")
  end
end

bot = GitterDumbDevBot.new
bot.start()