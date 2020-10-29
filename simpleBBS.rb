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
end

post '/new' do
    # 時間の取得
    time = Time.now
    # 書き込まれた書き込みの一つ前の書き込みのIDを取得
    id_count = Write.select('id').last

    # 最初の書き込みだったらID:1を付与
    if id_count != nil
        id_count = id_count.id
    else
        id_count = 1
    end

    # 書き込み数が1000件超えるとき
    if id_count != nil and id_count > 999
        redirect '/error'
    end

    # 書き込まれた名前とメッセージを変数に格納
    name = params[:name]
    message = params[:message]

    # 文字数を超えないように制限
    if name.length >= 200
        name = name.slice(0..199)
    elsif message.length >= 500
        message = message.slice(0..499)
    end

    # サニタイジング
    name = CGI.escapeHTML(name)
    message = CGI.escapeHTML(message)

    # fontのみ許可
    #message = CGI.unescapeElement(message, 'font')
    # fontタグが閉じ忘れていた場合追加
    #if message.index('</font>') == nil
    #    message = CGI.escapeHTML(message) + '</font>'
    #elsif message.match(/<font>.*?<\/font>/) == true
        #message = CGI.escapeHTML(message)
    #end

    # 改行の対応
    message = message.gsub(/(\r\n|\n|\r)/, '<br>')

    #pp name
    #pp message
    #pp message.index('<font></font>')
    
    s = Write.new
    #s.id = id_count.id
    if name == ""
        s.name = "名無しのJ科生" # もしも名前が書き込まれなかったら
    else
        s.name = name
    end

    # 隠しコマンド
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

get '/error' do
    erb :error
end
