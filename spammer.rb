require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'mail'

Mail.defaults do
  delivery_method :smtp, { :address   => "smtp.sendgrid.net",
                           :port      => 587,
                  			   :domain    => 'heroku.com',
                           :user_name => ENV['SENDGRID_USERNAME'],
                           :password  => ENV['SENDGRID_PASSWORD'],
                           :authentication => 'plain'}
end

before do
  new_params = {}
  params.each_pair do |full_key, value|
    this_param = new_params
    split_keys = full_key.split(/\]\[|\]|\[/)
    split_keys.each_index do |index|
      break if split_keys.length == index + 1
      this_param[split_keys[index]] ||= {}
      this_param = this_param[split_keys[index]]
   end
   this_param[split_keys.last] = value
  end
  request.params.replace new_params
end

get '/' do
  File.new('public/index.html').readlines
end

get '/mail' do
  mail = Mail.deliver do
    to params[:to]
    from params[:from]
    subject 'This is the subject of your email'
    text_part do
      body 'Hello world in text'
    end
    html_part do
      content_type 'text/html; charset=UTF-8'
      body '<b>Hello world in HTML</b>'
    end
  end
end
