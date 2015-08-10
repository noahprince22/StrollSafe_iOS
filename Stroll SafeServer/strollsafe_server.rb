require 'sinatra'
require 'twilio-ruby' 
require 'yaml'

post '/message' do
  config = YAML.load_file('config.yml')

  puts "Text initiating with params #{params}" 

  # set up a client to talk to the Twilio REST API 
  @client = Twilio::REST::Client.new config[:account_sid], config[:auth_token] 
  @client.account.messages.create({
  	:from => '+12403497236',
        :to => params["to"],
        :body => params["body"]    
  })  
end
