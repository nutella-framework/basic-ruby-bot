require 'simple_ruby_mqtt_client'
require 'json'
require 'set'

# Parse arguments
# Connect to MQTT
# Implement higher level publish/subscribe/unsubscribe/sync_req/async_req

class String
  def is_json?
    begin
      !!JSON.parse(self)
    rescue
      false
    end
  end
end


class Nutella
  
  def init(args)
    bot_name = args[0] + '_' + config_bot_name
    bot_name = bot_name[0, 23]
    @sc = SimpleMQTTClient.new(args[1], bot_name)
    @last_requests = Set.new
  end
  
  def config_bot_name 
    h = JSON.parse( IO.read( "nutella.json" ) )
    return h["name"]
  end
  
  def subscribe (channel, callback)
    @sc.subscribe(channel, callback)    
  end
  
  def sync_req (channel, message)
    # Generate message unique id
    id = message.hash 
    # Attach id
    payload = attach_message_id(message, id)
    # Initialize response and response counter
    ready_to_go = 2
    response = nil
    # Subscribe to same channel to collect response
    @sc.subscribe(channel, lambda do |p|
      p_h = JSON.parse(p)
      if (p_h["id"]==id)
        ready_to_go -= 1
        if ready_to_go
          @sc.unsubscribe(channel)
          response = p
        end
      end
    end)
    # Send message the message
    @sc.publish(channel, payload)
    # Wait for the response to come back
    sleep(0.5) until ready_to_go==0
    response
  end
  
  def async_req (channel, message, callback)
    # Generate message unique id
    id = message.hash 
    # Attach id
    payload = attach_message_id(message, id)
    # Register callback to handle data returned by the request
    ready_to_go = false
    @sc.subscribe(channel, lambda do |m|
      p_h = JSON.parse(m)
      if p_h["id"]==id
        if ready_to_go
          @sc.unsubscribe(channel)
          callback.call(m)
        else
          ready_to_go = true
        end
      end
    end)
    # Send message
    @sc.publish(channel, payload)
  end
  
  # Hadles requests on a certain channel
  def handle_requests (channel, &handler)
    @sc.subscribe(channel, lambda do |m|
      begin
        req = JSON.parse(m)
        id = req["id"]
        if id.nil?
          raise
        end
      rescue
        # Ignore anything that's not JSON
        return
      end
      # Ignore recently processed requests
      if @last_requests.include?(id)
        @last_requests.delete(id)
        return
      end
      @last_requests.add(id)
      req.delete("id")
      res = handler.call(req)
      if !res.is_a?(Hash)
        raise TypeError.new 'Your block needs to return a Hash!'
      end
      res[:id]=id
      @sc.publish(channel, res.to_json)
    end)
  end
  
  
  private 
  
  def attach_message_id (message, id) 
    if message.is_a?(Hash)
      message[:id] = id
      payload = message.to_json
    elsif message.is_json?
      p = JSON.parse(message)
      p[:id] = id
      payload = p.to_json
    elsif message.is_a?(String)
      payload = { :payload => message, :id => id }.to_json
    end
    payload
  end
end



n = Nutella.new;
n.init(ARGV)
# res = n.sync_req( "req", 'ciccia' )
# n.async_req( "req", 'ciccia', lambda do |response|
#   puts "async_req response: #{response}"
# end)
n.handle_requests("req") do |req| 
  {:response => "my response to request #{req} from channel REQ" }
end
begin
  while true
    sleep(5)
  end
rescue Interrupt
  # terminates
end
