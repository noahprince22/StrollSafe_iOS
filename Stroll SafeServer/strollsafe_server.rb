require 'sinatra'
require 'twilio-ruby' 
require 'yaml'
require 'sinatra_ssl'

set :port, 8443
set :ssl_certificate, "server.crt"
set :ssl_key, "server.key"

post '/message' do
  config = YAML.load_file('config.yml')

  puts "Text initiating with params #{params}" 

  # set up a client to talk to the Twilio REST API 
  @client = Twilio::REST::Client.new config[:account_sid], config[:auth_token] 
  @client.account.messages.create({
  	:from => params['phone'],
    :to => params["to"],
    :body => params["body"]    
  })  
end

def build_body_from_params(params)
  return "#{params['body']}\nFrom: #{params['name']}\n uuid: #{params['uuid']}\n digits_id: #{params['digits_id']}\n phone: #{params['phone']}"
end

post '/feature' do
  puts params

  Mail.deliver do
    delivery_method :sendmail
    from "#{params['name']}@strollsafe"
    to 'noahprince8@gmail.com'
    subject "[FEATURE] #{params['subject']}"
    body build_body_from_params(params)
  end
end

post '/bug' do
  puts params
 
  Mail.deliver do
    from "#{params['phone']}@strollsafe"
    to 'noahprince8@gmail.com'
    subject "[BUG] #{params['subject']}"
    body build_body_from_params
  end
end
