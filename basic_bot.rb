puts "I'm just a stupid bot that prints the argument it received."
puts "Argument is: #{ARGV[0]}"
puts "Now I'm just gonna sleep 5 seconds and print forever"

begin
  i=0
  while true
    sleep(5)
    puts "#{i+=1}. I slept 5 seconds!"
  end
rescue Interrupt
  # terminates
end
