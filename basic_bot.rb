require 'nutella_lib'


# Parse command line arguments
broker, app_id, run_id = nutella.parse_args ARGV
# Extract the component_id
component_id = nutella.extract_component_id
# Initialize nutella
nutella.init(broker, app_id, run_id, component_id)
# (Optional) Set the resourceId
nutella.set_resource_id 'my_resource_id'



puts "Hi, I'm a basic ruby bot and your code should go here!"


# Examples
# You can do things such as:


# 0. Accessing properties exposed by nutella library
# puts nutella.app_id
# puts nutella.run_id
# puts nutella.component_id
# puts nutella.resource_id


# 1. Subscribing to a channel
# nutella.net.subscribe('demo_channel', lambda do |message, component_id, resource_id|
#   #Your code to handle messages received on this here
# end)

	
# 2. Subscribe to a wildcard channel (a.k.a. more than one channel at the same time,
# in the example below we'll receive messages on demo_channel/a, demo_channel/a/b, demo_channel/c, etc.)
# nutella.net.subscribe('demo_channel/#', lambda do |message, channel, component_id, resource_id|
#   # Your code to handle messages received by this channel here
# end)


# 3. Publish a message to a channel
# nutella.net.publish( 'demo_channel', 'demo_message' );

	
# 3a. The cool thing is that the message can be any Hash
# nutella.net.publish('demo_channel', {a: 'proper', key: 'value'});

	
# 4. Make synchronous requests on a certain channel...
# response =  nutella.net.sync_request( 'demo_channel', 'my_request' )

	
# 4a. ... and, guess what, we can send any hash in a request, like in publish.
# Requests can even be empty, kind of like a GET
# response = nutella.net.sync_request 'demo_channel'
# # Your code to handle the response here


# 5. Make asynchronous requests. Exactly like 4 but asynchronous.
# nutella.net.async_request( 'demo_channel', 'my_request', lambda do |response|
#   # Your code to handle the response here
# end)


# 5a. That includes empty requests of course
# nutella.net.async_request( 'demo_channel', lambda do |response|
#   # Your code to handle the response here
# end)


# 6. Handle requests from other components
# nutella.net.handle_requests( 'demo_channel', lambda do |message, component_id, resource_id|
#   # Your code to handle each request here
#   # Anything this function returns (String, Integer, Hash...) is going to be sent as the response
#   # response = 'a simple string'
#   # response = 12345
#   # response = {}
#   # response = {my:'json'}
#   # response
# end)
	

# Just sit here waiting for messages to come
nutella.net.listen
