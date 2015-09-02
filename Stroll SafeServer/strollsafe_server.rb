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

post '/feature' do
  puts params

  Mail.deliver do 
    from "#{params['phone']}@strollsafe"
    to 'noahprince8@gmail.com'
    subject "[FEATURE] #{params['subject']}"
    body "#{params['body']}\nFrom: #{params['name']}"
  end
end

post '/bug' do
  puts params
 
  Mail.deliver do
    from "#{params['phone']}@strollsafe"
    to 'noahprince8@gmail.com'
    subject "[BUG] #{params['subject']}"
    body "#{params['body']}\nFrom: #{params['name']}"
  end
end
