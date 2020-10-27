require 'sinatra'
require 'active_record'
require "cgi/escape"
require 'pp'

set :environment, :production

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection :development

# ActiveRecordのBaseを継承
class Write < ActiveRecord::Base
end

get '/'do
    @s = Write.all
    erb :index
end;

post '/new' do
    # 時間の取得
    time = Time.now
    # 書き込まれた書き込みの一つ前の書き込みのIDを取得
    id_count = Write.select('id').last
    if id_count == nil
        id_count = 1
    else
        id_count.id += 1
    end

    # 書き込まれた名前とメッセージを変数に格納
    name = params[:name]
    message = params[:message]

    # サニタイジング
    name = CGI.escapeHTML(name)
    message = CGI.escapeHTML(message)

    # fontのみ許可
    message = CGI.unescapeElement(message, "font")

    # 改行の対応
    message = message.gsub(/(\r\n|\n|\r)/, '<br>')

    pp name
    pp message
    
    s = Write.new
    s.id = id_count.id
    if name == ""
        s.name = "名無しのJ科生" # もしも名前が書き込まれなかったら
    else
        s.name = name
    end

    if message == "Cat Cat Cat"
        message = "　　　　　 ∧,,∧<br>
        　　　　　(,,・∀・)<br>
        　　　　～(_ｕ,ｕ<br>"
    end

    s.write_time = time
    s.message = message
    s.save
    redirect '/'
end

delete '/del' do
    s = Write.find(params[:id])
    s.destroy
    redirect '/'
end
