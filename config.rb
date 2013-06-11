require 'sinatra/base'
require 'sprockets'
require 'sprockets-helpers'
require 'sprockets-cache-redis'
require 'redis'
require 'rake/sprocketstask'
require 'haml_coffee_assets'

class App < Sinatra::Base
  set :sprockets, Sprockets::Environment.new
  set :assets_prefix, '/assets'
  set :digest_assets, false
  set :redis, Redis.new(:host => 'localhost', :port => 6379)
  set :compiled_template_name, "index.html"

  set :output_directory, "public/"
  set :output_directory_android, "android/assets/www/"
  set :output_directory_ios, "ios/www/"
  set :output_directory_blackberry, "blackberry/www/"

  configure do

    HamlCoffeeAssets.config.namespace = "window.HAML"
    HamlCoffeeAssets.config.escapeHtml = false
    HamlCoffeeAssets.config.escapeAttributes = false
    HamlCoffeeAssets.config.cleanValue = false
    HamlCoffeeAssets.config.context = false

    sprockets.append_path File.join(root, 'assets', 'stylesheets')
    sprockets.append_path File.join(root, 'assets', 'javascripts')
    sprockets.append_path File.join(root, 'assets', 'images')

    sprockets.cache = Sprockets::Cache::RedisStore.new(redis, 'sprockets')

    Sprockets::Helpers.configure do |config|
      config.environment = sprockets
      config.prefix      = assets_prefix
      config.digest      = digest_assets
      config.public_path = public_folder

      config.default_path_options = {
          :audio_path => { :dir => 'audios' },
          :font_path => { :dir => 'fonts' },
          :image_path => { :dir => 'assets/images' },
          :javascript_path => { :dir => 'assets/javascripts', :ext => 'js' },
          :stylesheet_path => { :dir => 'assets/stylesheets', :ext => 'css' },
          :video_path => { :dir => 'videos' }
      }
    end

  end

  helpers do
    include Sprockets::Helpers
  end

  get '/' do
    erb :index
  end
end
