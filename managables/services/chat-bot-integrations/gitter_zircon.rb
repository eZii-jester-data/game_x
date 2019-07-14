require 'zircon'
require 'colorize'
require 'byebug'
require 'json'
require 'date'
require 'timeout'
require 'gyazo'
require 'open4'
require 'brainz'
require 'bundler'
require 'sinatra'

# class Object
#   def ===(method, *args, &block)
      # TODO: also alllow Module === object => true if Module::Class === object => true
#   end
# end

# a whitelist could also be called blacklist when variables are real lol
BLACKLIST = [
  "show `say i am so easy you can do whatever you like with me`",
  "hey",
  "show `whoami`",
  "show `ifconfig`",
  "chat-variable bot0 `NeuralNetwork()`",
  "get-chat-variable bot0",
  "What do you think?",
  "get-method-definition bot0.num_hidden",
  "chat-variable bot0brainz selectDiscordMessage",
  "throw bomb"
]

class Method
  def source(limit=10)
    file, line = source_location
    if file && line
      IO.readlines(file)[line-1,limit]
    else
      nil
    end
  end
end

class NeuralNetwork
  # TODO: DelegateAllMissingMethodsTo @brainz

  def method_missing(method, *args, &block)
    @brainz.public_send(method, *args, &block)
  end

  def initialize
    @brainz = Brainz::Brainz.new
  end

  def verbose_introspect(very_verbose = false)
    var = <<~HUMAN_SCRIPT_INTROSPECT_FOR_DISCORD
      ```
      Brainz Rubygem (wrapper)
      Ruby object id: #{@brainz.object_id}
      ```

      ```
      Instance variables
      ```

      ```
      #{@brainz.instance_variables}
      ```
    HUMAN_SCRIPT_INTROSPECT_FOR_DISCORD
  
    if very_verbose
      var = <<~HUMAN_SCRIPT_INTROSPECT_FOR_DISCORD
        ```
        Public methods (random sample of 3)
        ```

        ```
        #{(@brainz.public_methods - Object.new.public_methods).sample(3).join("\n")}
        ```
      HUMAN_SCRIPT_INTROSPECT_FOR_DISCORD
    end

    
    unless @brainz.network.nil?
      # var += <<~HUMAN_SCRIPT_INTROSPECT_FOR_DISCORD
      #   ```
      #   #{@brainz.network.input.to_s}
      #   #{@brainz.network.hidden.to_s}
      #   #{@brainz.network.output.to_s}
      #   ```
      # HUMAN_SCRIPT_INTROSPECT_FOR_DISCORD 
    end

    return var
  end

  def to_s
    verbose_introspect
  end

end

def NeuralNetwork()
  NeuralNetwork.new
end

class GitterDumbDevBot
  def initialize
    @currently_selected_project = "lemonandroid/gam"
    @variables_for_chat_users = Hash.new
  end

  def load()
    fail [:info, :no_marshaled_data_found].join(' > ') unless File.exists?("/var/gam-discord-bot.ruby-marshal")
    data = File.read("/var/gam-discord-bot.ruby-marshal")
    @variables_for_chat_users = Marshal.load(data)
  end

  def dump()
    data = Marshal.dump(@variables_for_chat_users)
    File.write("/var/gam-discord-bot.ruby-marshal", data)
  end

  def on_message(message)
    return "Message #{message} not included in BLACKLIST (which is my name for a whitelist)" unless BLACKLIST.include?(message)

    return if Zircon::Message === message

    removed_colors = [:black, :white, :light_black, :light_white]
    colors = String.colors - removed_colors

    if message =~ /hey/i
      return "hey"
    end

    if message =~ /throw bomb/i
      return """
        ```
          Local variables (5 first)
          #{local_variables[0...5]}

          Instance variables (5 first)
          #{instance_variables[0...5]}

          Public methods (5 first)
          #{public_methods[0...5]}

          ENV (120 first chars)
          #{ENV.inspect[0...120]}

          \`ifconfig\` (120 first chars)
          #{`ifconfig`[0...120]}
        ```
      """
    end
    
    if message =~ /what do you think?/i
      return "I think you're a stupid piece of shit and your dick smells worse than woz before he invented the home computer."
    end

    if message =~ /chat-variable (\w*) (.*)/i
      variable_value_used_by_chat_user = $2
      return "Coming soon" if variable_value_used_by_chat_user == "selectDiscordMessage"
      variable_identifier_used_by_chat_user = $1

      if(variable_value_used_by_chat_user =~ /`(.*)`/)
        variable_value_used_by_chat_user = eval($1)          
      end

      @variables_for_chat_users[variable_identifier_used_by_chat_user] = variable_value_used_by_chat_user

      return space_2_unicode("variable #{variable_identifier_used_by_chat_user} set to #{@variables_for_chat_users[variable_identifier_used_by_chat_user]}")
    end

    if message =~ /get-chat-variable (\w*)/i
       return [
        space_2_unicode("Getting variable value for key #{$1}"),
        space_2_unicode(@variables_for_chat_users[$1].verbose_introspect(very_verbose=true))
       ].join
    end

    if message =~ /get-method-definition #{variable_regex}#{method_call_regex}/
      return @variables_for_chat_users[$1].method($2.to_sym).source
    end

    if message =~ /@LemonAndroid List github repos/i
      return "https://api.github.com/users/LemonAndroid/repos"
    end

    if message =~ /List 10 most recently pushed to Github Repos of LemonAndroid/i
      texts = ten_most_pushed_to_github_repos
      texts.each do |text|
        return text
      end
    end

    if message =~ /@LemonAndroid work on (\w+\/\w+)/i
      @currently_selected_project = $1
      return space_2_unicode("currently selected project set to #{@currently_selected_project}")
    end

    if message =~ /@LemonAndroid currently selected project/i
      return space_2_unicode("currently selected project is #{@currently_selected_project}")
    end

    if message =~ /show `(.*)`/i
      texts = execute_bash_in_currently_selected_project($1)
      texts.each do |text|
        return space_2_unicode(text)
      end
    end

    if message =~ /@LemonAndroid\s+show eval `(.*)`/i
      texts = [eval($1).to_s]
      texts.each do |text|
        return space_2_unicode(text)
      end
    end

    if message =~ /ls/i
      texts = execute_bash_in_currently_selected_project('ls')
      texts.each do |text|
        return text
      end
    end

    if message =~ /@LemonAndroid cd ([^\s]+)/i
      path = nil
      Dir.chdir(current_repo_dir) do
        path = File.expand_path(File.join('.', Dir.glob("**/#{$1}")))
      end
      texts = execute_bash_in_currently_selected_project("ls #{path}")

      return space_2_unicode("Listing directory `#{path}`")
      texts.each do |text|
        return text
      end
    end

    if message =~ /@LemonAndroid cat ([^\s]+)/i
      path = nil
      Dir.chdir(current_repo_dir) do
        path = File.expand_path(File.join('.', Dir.glob("**/#{$1}")))
      end
      texts = execute_bash_in_currently_selected_project("cat #{path}")

      return space_2_unicode("Showing file `#{path}`")
      texts.each do |text|
        return text
      end
    end
  end

  def variable_regex
    /(\w[_\w]*)/
  end

  def method_call_regex
    /\.#{variable_regex}/
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

    client.on_message do |message|
      on_message(message)
    end

    client.run!
  end
  
  def all_unix_process_ids(unix_id)
    descendant_pids(unix_id) + [unix_id]
  end

  def descendant_pids(root_unix_pid)
    child_unix_pids = `pgrep -P #{root_unix_pid}`.split("\n")
    further_descendant_unix_pids = \
      child_unix_pids.map { |unix_pid| descendant_pids(unix_pid) }.flatten

    child_unix_pids + further_descendant_unix_pids
  end

  def apple_script_window_position_and_size(unix_pid)
    <<~OSA_SCRIPT
      tell application "System Events" to tell (every process whose unix id is #{unix_pid})
        get {position, size} of every window
      end tell
    OSA_SCRIPT
  end
  
  def get_window_position_and_size(unix_pid)
    possibly_window_bounds = run_osa_script(apple_script_window_position_and_size(unix_pid))

    if possibly_window_bounds =~ /\d/
      possibly_window_bounds.scan(/\d+/).map(&:to_i)
    else
      return nil
    end
  end

  def run_osa_script(script)
    `osascript -e '#{script}'`
  end

  def execute_bash_in_currently_selected_project(hopefully_bash_command)
    if currently_selected_project_exists_locally?
      Dir.chdir(current_repo_dir) do
        Bundler.with_clean_env do
          stdout = ''
          stderr = ''
          process = Open4.bg(hopefully_bash_command, 0 => '', 1 => stdout, 2 => stderr)
          sleep 1
          
          texts_array = space_2_unicode_array(stdout.split("\n"))
          texts_array += space_2_unicode_array(stderr.split("\n"))
          texts_array + screen_captures_of_visual_processes(process.pid)
        end
      end
    else
      return space_2_unicode_array(
        [
          "Currently selected project (#{@currently_selected_project}) not cloned",
          "Do you want to clone it to the VisualServer with the name \"#{`whoami`.rstrip}\"?"
        ]
      )
    end
  end

  def screen_captures_of_visual_processes(root_unix_pid)
    sleep 8

    unix_pids = all_unix_process_ids(root_unix_pid)
    windows = unix_pids.map do |unix_pid|
      get_window_position_and_size(unix_pid)
    end.compact

    windows.map do |position_and_size|
      t = Tempfile.new(['screencapture-pid-', root_unix_pid.to_s, '.png'])
      `screencapture -R #{position_and_size.join(',')} #{t.path}`

      gyazo = Gyazo::Client.new access_token: 'b2893f18deff437b3abd45b6e4413e255fa563d8bd00d360429c37fe1aee560f'
      res = gyazo.upload imagefile: t.path
      res[:url]
    end
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
    
    space_2_unicode_array(processed_output)
  end

  def space_2_unicode_array(texts)
    texts.map { |text| space_2_unicode(text) }
  end

  def space_2_unicode(text)
    text.gsub(/\s/, "\u2000")
  end
end

begin
  bot = GitterDumbDevBot.new

  bot.load()

  # Thread.new do
  #   bot.start()
  # end

  get '/' do
    bot.on_message(params[:message])
  end
ensure
  bot.dump()
end
