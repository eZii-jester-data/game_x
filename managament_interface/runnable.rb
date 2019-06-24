require 'ruby2d'

# Set the window size
set width: 400, height: 400

set title: "Fun first"

Text.new('Managables', y: 0)
    Text.new('  Games', y: 20)
        Text.new('    Game Aided Manufacturing', y: 40)

        
    Text.new('  Services', y: 60)
        Text.new('    Error Web App', y: 80)
        Text.new('    Vision/OCR', y: 100)
        Text.new('    Livestream Interactive', y: 120)


on :mouse_up do |event|
    # x and y coordinates of the mouse button event
    case event.button
    when :left
        puts event.x
        puts event.y
    end
end


# Show the window
show