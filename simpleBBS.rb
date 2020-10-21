require 'sinatra'
require 'active_record'

set :environment, :production

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection :development

# ActiveRecordのBaseを継承
class Write < ActiveRecord::Base
end

get '/'do
    @s = Write.all
    erb :index
end

post '/new' do
    s = Write.new
    s.id = params[:id]
    s.name = params[:name]
    s.write_time = params[:time]
    s.message = params[:message]
    s.save
    redirect '/'
end

delete '/del' do
    s = Write.find(params[:id])
    s.destroy
    redirect '/'
end

