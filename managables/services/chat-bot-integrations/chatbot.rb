
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
require 'nokogiri'

# class Object
#   def ===(method, *args, &block)
      # TODO: also alllow Module === object => true if Module::Class === object => true
#   end
# end

def optional_prefix(prefix, message)
  [prefix + message, message]
end

EEZEE_PREFIX = "eezee" + " "

ALLOWED_MESSAGES_LIST = [
  "fuck it",
  "install ruby",
  "do something useful",
  "know context?",
  "like do you know context you dum dum?",
  "show `man ruby`",
  "show `man netstat`",
  "show `man telnet`",
  "show `man traceroute`",
  "lifecycle",
  "bleeding",
  "bleeding lifecycle",
  "melt",
  "get-liquids-after-melting-point",
  "probe last message full version size"
].map do |message|
  optional_prefix(EEZEE_PREFIX, message)
end.flatten

# DISALLOWED_MESSAGES_LIST = [
#   `rm -rf /tmp`,
#   'rm -rf /',
#   'rm',
#   'show `rm -fr /`',
#   'show eval `exec("rm -fr")`'
# ]

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
    @players = Hash.new do |dictionary, identifier| 
      dictionary[identifier] = Hash.new
    end
    @melting_point_receivables = ["puts 'hello word'"]
    @probes = []
    @melted_liquids = []
    @sent_messages = []
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

  def twitch_username_from_url(url)
    url.match(/\/(\w*)\Z/)[1]
  end

  def record_live_stream_video_and_upload_get_url(url:, duration_seonds:)
    twitch_username = twitch_username_from_url(url)
    twitch_broadcaster_id = JSON.parse(`curl -H 'Authorization: Bearer #{ENV['EZE_TWITCH_TOKEN']}' \
    -X GET 'https://api.twitch.tv/helix/users?login=#{twitch_username}'`)["data"][0]["id"]
    created_clip_json_response = `curl -H 'Authorization: Bearer #{ENV['EZE_TWITCH_TOKEN']}' \
    -X POST 'https://api.twitch.tv/helix/clips?broadcaster_id=#{twitch_broadcaster_id}'`

    created_clip_json_response = JSON.parse(created_clip_json_response)
    
    id = created_clip_json_response["data"][0]["id"]
    return "https://clips.twitch.tv/#{id}"

    # return `curl -H 'Authorization: Bearer #{ENV['EZE_TWITCH_TOKEN']}' \
    # -X GET '#{url}'`
  end

  def get_string_of_x_bytes_by_curling_url(url:, byte_count:)
    str = `curl #{url}`
    sub_zero_string = str.each_char.reduce("") do |acc, chr| # haha, sub sero string
      unless acc.bytesize === byte_count
        acc += chr
      else
        break acc
      end
    end

    "`#{sub_zero_string.unpack('c*')}`"
  end
  
  def on_message(message)
    require 'wit'

    client = Wit.new(access_token: ENV["WIT_AI_TOKEN"])
    response = client.message(message)

    server_client = Wit.new(access_token: ENV['WIT_AI_TOKEN_SERVER'])
    if message =~ /new entity for wit.ai eezee probe explainer\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s+(\w+)\s*/i
      wit_ai_entity_payload = {
        doc: $1,
        id: $2,
        values:[
          {
            value: $3,
            expressions:
              [
                $4,
                $5,
                $6
              ]
          }
        ]
      }
      begin
        response = server_client.post_entities(wit_ai_entity_payload)
      rescue Exception => e
        return """
          #{e.inspect}
          #{e.message}
        """
      end

      return """
        New entity created on wit.ai #{$1}

        #{response[0...140]}
      """
    end

    if message =~ /get postgresql url/
      `rails new myapp --database=postgresql`
      `cd myapp`
      `
      git init
      git add .
      git commit -m "init"
      `

      `heroku create`
      `git push heroku master`
    end

    return ""
    # return response.inspect[0...250]





















    message.gsub!(EEZEE_PREFIX, '')

    # return "Message #{message} not included in ALLOWED_MESSAGES_LIST (which is my name for a whitelist)" unless ALLOWED_MESSAGES_LIST.include?(message)
    return "" unless ALLOWED_MESSAGES_LIST.include?(message)
    warn "Message #{message} not included in ALLOWED_MESSAGES_LIST (which is my name for a whitelist)" unless ALLOWED_MESSAGES_LIST.include?(message)

    return if Zircon::Message === message

    removed_colors = [:black, :white, :light_black, :light_white]
    colors = String.colors - removed_colors

    if message =~ /fuck it/
      return "https://pbs.twimg.com/media/D_ei8NdXkAAE_0l.jpg:large"
    end

    if message =~ /lifecycle/ && rand > 0.5
      return """
        LEARN -> IDEAS - BUILD -> CODE - MEASURE -> DATA - go back to \\A
      """
    end

    if message =~ /bleeding/ && rand > 0.5
      return "extremely negative capital flow. go broke or die"
    end

    if message =~ /bleeding lifecycle/ && rand > 0.2
      return "lifecycle IDEAS -> CODE -> MEASURE -> GO OUT PICK TRASH UP -> COLLECT ALL MONEY AND DONATE ON BETTERPLACE -> go back to \\A"
    end

    if message =~ /install ruby/
      return "are you a webpacker or a bundlerine?"
    end

    if message =~ /do something useful/
      return "i'm learning, go pick trash outside while i suprass you in every possible way!"
    end
    
    # if message =~ /know context?/ && rand > 0.2
    #   return "huh?"
    # end

    if message =~ /like do you know context you dum dum?/
      # return "http://gazelle.botcompany.de/"
      byebug
      doc = Nokogiri::HTML(`curl -L http://gazelle.botcompany.de/lastInput`)

      return doc.css('*').map(&:inspect).inspect[0...100]
    end

    if message =~ /bring probes to melting point/
      @melting_point_receivables.push(@probes)
      @probes = []
      return "all of them? melt all the precious probes you idiot?"
    end

    if message =~ /probe (.*) (.*)/
      action = :log

      resource = $1
      probe_identifier = $2

      if probe_identifier =~ /(\d+)s/
        duration_seconds = $1.to_i
      end

      if probe_identifier =~ /(\d+)bytes/
        byte_count = $1.to_i
      end

      case resource
      when /twitch.tv/
        twitch_url = resource
        action = :twitch
      when /http/
        action = :plain_curl
        url = resource
      end

      case action
      when :twitch
        probe = record_live_stream_video_and_upload_get_url(url: twitch_url, duration_seonds: duration_seconds)
        @probes.push(probe)
        return probe
      when :plain_curl
        probe = get_string_of_x_bytes_by_curling_url(url: url, byte_count: byte_count)
        @probes.push(probe)
        return probe
      end
    end

    if message =~ /show activity stream/
      return "https://sideways-snowman.glitch.me/"
    end

    if message =~ /hey\Z/i
      return "hey"
    end

    if message =~ /\Athrow bomb\Z/i
      return """
        ```
          Local variables (5 first)
          #{local_variables.sample(5)}

          Instance variables (5 first)
          #{instance_variables.sample(5)}

          Public methods (5 first)
          #{public_methods.sample(5)}

          ENV (120 first chars)
          #{ENV.inspect[0...120]}

          \`ifconfig\` (120 first chars)
          #{`ifconfig`[0...120]}
        ```
      """
    end

    if message =~ /\Abring to melting point #{melting_point_receiavable_regex}\Z/i
      if($1 === "last used picture")
        Nokogiri::HTML(`curl -L http://gazelle.botcompany.de/lastInput`)

        url = doc.css('a').first.url

        @melting_point_receivables.push(url)
      end
      @melting_point_receivables.push($1)
    end

    if message =~ /get-liquids-after-melting-point/
      @sent_messages.push(
        [@melted_liquids.inspect, @melted_liquids.inspect[0...100]]
      )
      return @sent_messages[-1][1]
    end

    if message =~ /probe last message full version size/
      return @sent_messages[-1][0].bytesize.to_s + 'bytes'
    end

    if message =~ /\Amelt\Z/
      # First step, assigning a variable
      @melting_point = @melting_point_receivables.sample

      def liquidify_via_string(object)
        object.to_s.unpack("B*")
      end
      liquid = liquidify_via_string(@melting_point)

      @melted_liquids.push(liquid)

      return "Melted liquid which is now #{liquid.object_id} (ruby object id)"
      # Next step, doing something intelligent with the data
      # loosening it up somehow
      # LIQUIDIFYING IT
      # CONVERTING IT ALL TO BYTES
      # PRESERVING VOLUME, just changing it's "Aggregatzustand"
    end

    if message =~ /\Aget-melting-point\Z/
      return @melting_point
    end

    if message =~ /launch rocket (.*)\]var\[(.*)/
      url = $1 + @melting_point + $2
      curl_response = `curl -L #{url}`[0...100]

      return """
        CURL
        #{curl_response}

        URL
        #{url}
      """
    end 
    
    if message =~ /\Awhat do you think?\Z/i
      return "I think you're a stupid piece of shit and your dick smells worse than woz before he invented the home computer."
    end

    if message =~ /\Apass ball to @(\w+)\Z/i
      @players[$1][:hasBall] = :yes
    end

    if message =~ /\Awho has ball\Z/i
      return @players.find { |k, v| v[:hasBall] == :yes }[0]
    end

    if message =~ /\Aspace\Z/
      exec_bash_visually_and_post_process_strings(
        '/Users/lemonandroid/gam-git-repos/LemonAndroid/gam/managables/programs/game_aided_manufacturing/test.sh'
      )
    end

    if message =~ /\Achat-variable (\w*) (.*)\Z/i
      variable_value_used_by_chat_user = $2
      return "Coming soon" if variable_value_used_by_chat_user == "selectDiscordMessage"
      variable_identifier_used_by_chat_user = $1

      if(variable_value_used_by_chat_user =~ /`(.*)`/)
        variable_value_used_by_chat_user = eval($1)          
      end

      @variables_for_chat_users[variable_identifier_used_by_chat_user] = variable_value_used_by_chat_user

      return space_2_unicode("variable #{variable_identifier_used_by_chat_user} set to #{@variables_for_chat_users[variable_identifier_used_by_chat_user]}")
    end

    if message =~ /\Aget-chat-variable (\w*)\Z/i
       return [
        space_2_unicode("Getting variable value for key #{$1}"),
        space_2_unicode(@variables_for_chat_users[$1].verbose_introspect(very_verbose=true))
       ].join
    end

    if message =~ /\Aget-method-definition #{variable_regex}#{method_call_regex}\Z/
      return @variables_for_chat_users[$1].method($2.to_sym).source
    end

    if message =~ /\A@LemonAndroid List github repos\Z/i
      return "https://api.github.com/users/LemonAndroid/repos"
    end

    if message =~ /\AList 10 most recently pushed to Github Repos of LemonAndroid\Z/i
      texts = ten_most_pushed_to_github_repos
      texts.each do |text|
        return text
      end
    end

    if message =~ /\A@LemonAndroid work on (\w+\/\w+)\Z/i
      @currently_selected_project = $1
      return space_2_unicode("currently selected project set to #{@currently_selected_project}")
    end

    if message =~ /@LemonAndroid currently selected project/i
      return space_2_unicode("currently selected project is #{@currently_selected_project}")
    end

    if message =~ /\Ashow `(.*)`\Z/i
      test = $1
      return exec_bash_visually_and_post_process_strings(test)
    end

    if message =~ /\A@LemonAndroid\s+show eval `(.*)`\Z/i
      texts = [eval($1).to_s]
      texts.each do |text|
        return space_2_unicode(text)
      end
    end

    if message =~ /\Als\Z/i
      texts = execute_bash_in_currently_selected_project('ls')
      texts.each do |text|
        return text
      end
    end

    if message =~ /\A@LemonAndroid cd ([^\s]+)\Z/i
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

    if message =~ /\A@LemonAndroid cat ([^\s]+)\Z/i
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

  def exec_bash_visually_and_post_process_strings(test)
    texts = execute_bash_in_currently_selected_project(test)
    return texts.map do |text|
       space_2_unicode(text)
    end.join("\n")
  end

  def variable_regex
    /(\w[_\w]*)/
  end

  def method_call_regex
    /\.#{variable_regex}/
  end

  def melting_point_receiavable_regex
    /(.*)/
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
          sleep 0.5

          
          texts_array = space_2_unicode_array(stdout.split("\n"))
          texts_array += space_2_unicode_array(stderr.split("\n"))

          return [texts_array[1][0...120]]
          # texts_array + screen_captures_of_visual_processes(process.pid)
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
