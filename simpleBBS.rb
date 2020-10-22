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
    time = Time.now
    id_count = Write.select('id').last
    if id_count == nil
        id_count = 0
    else
        id_count.id += 1
    end
    s = Write.new
    s.id = id_count.id
    s.name = params[:name]
    s.write_time = time
    s.message = params[:message]
    s.save
    redirect '/'
end

delete '/del' do
    s = Write.find(params[:id])
    s.destroy
    redirect '/'
end

