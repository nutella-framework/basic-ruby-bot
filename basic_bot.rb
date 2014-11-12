require 'nutella_lib'

# Initialize nutella
nutella.init ARGV

puts "Hi, I'm a basic ruby bot and your code should go here!"

# Just sit there waiting for messages to come
nutella.net.listen
