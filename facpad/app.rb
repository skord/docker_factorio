require 'rubygems'
require 'bundler/setup'
Bundler.setup
require 'zip'
require 'json'
require 'sinatra'
require 'slim'
require 'uri'
require 'curb'

MODS_PATH = ENV['MODS_PATH']

class FactorioMods
  def initialize(mods_path)
    @mods_path = mods_path
  end

  def all
    mod_zips = Dir.glob(File.join(@mods_path, "*.zip"))
    mods = []
    mod_zips.each do |mod|
      Zip::File.open(mod) do |zf|
        infos = zf.glob("**/info.json")
        infos.each do |info|
          mods << JSON.parse(zf.read(info))
        end
      end
    end
    return mods
  end

  def install(url)
    uri = URI.parse(url)
    c = Curl::Easy.new
    c.follow_location = true
    c.max_redirects = 5
    c.url = uri.to_s
    c.perform
    # fucking assinine content header bullshit on the forums...
    if uri.host == "forums.factorio.com"
      filename = c.header_str.gsub("UTF-8''",'').scan(/filename.*=(.*)/)[0][0].chomp
    else
      filename = File.basename(uri.to_s)
    end
    File.open(File.join(@mods_path, filename), 'w') do |f|
      f.write c.body
    end
  end
end

class FactorioServer
  def self.status
    command("status")
  end

  def self.command(cmd)
    IO.popen("sudo sv #{cmd} factorio") {|io|
      string = io.read
    }
  end
end

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not Authorized"
  end
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV['FP_USERNAME'], ENV['FP_PASSWORD']]
  end
end

get '/' do
  slim :home
end

get '/mods' do
  @mods = FactorioMods.new(MODS_PATH).all
  slim :mods
end

get '/modpack' do
  Zip.continue_on_exists_proc = true
  mods = Dir.glob(File.join(MODS_PATH, "*.zip"))
  Zip::File.open('public/modpack.zip', Zip::File::CREATE) do |zipfile|
    mods.each do |f|
      zipfile.add(File.join("mods" + File.basename(f)), f)
    end
  end
  send_file 'public/modpack.zip'
end

post '/install' do
  protected!
  #params[:mod_url]
  mods = FactorioMods.new(MODS_PATH)
  mods.install(params[:mod_url])
  #slim :mods
  redirect to('/mods')
end

get '/server' do
  @status = FactorioServer.status
  slim :server
end

get '/server/:action' do
  protected!
  FactorioServer.command(params[:action])
  redirect to('/server')
end

get '/savegame' do
  protected!
  send_file("/opt/factorio/saves/savegame.zip")
end
