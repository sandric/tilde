require "rake/sprocketstask"
require 'fileutils'
require "./config"

project_root = File.expand_path(File.dirname(__FILE__))

def copy_folder_files(source_folder, destination_folder)
  FileUtils.rm_rf(destination_folder)
  if File.directory? source_folder
    FileUtils.cp_r(source_folder, destination_folder)
  else
    FileUtils.mkdir(destination_folder)
  end
end

def populate_platform_specific_files(platform)
  %w(javascripts stylesheets).each do |folder|
    copy_folder_files("assets/#{folder}/vendor/#{platform}", "assets/#{folder}/vendor/platform_specific")
  end
end

task :compile_assets do

  platform = ARGV.last

  populate_platform_specific_files(platform)

  request = Rack::MockRequest.new(App)
  template = request.get('/?compile=true').body
  File.open("#{project_root}/#{App.settings.instance_eval("output_directory_#{platform}")}index.html",'w'){ |f| f.write(template) }

  Rake::SprocketsTask.new do |t|
    t.environment = App.settings.sprockets

    t.output = App.settings.output_directory
    t.assets = %w( application.js application.css )
  end

  Rake::Task["assets"].reenable
  Rake::Task["assets"].invoke

  require 'find'
  Find.find(App.settings.output_directory) do |path|
    if File.file?(path)
      case File.extname(path)
        when '.js'
          filename = File.basename(path, ".js")
          unless filename.match(/application-.*/).nil?
            FileUtils.cp path, "#{project_root}/#{App.settings.instance_eval("output_directory_#{platform}")}js/application.js"
          end
        when '.css'
          filename = File.basename(path, ".css")
          unless filename.match(/application-.*/).nil?
            FileUtils.cp path, "#{project_root}/#{App.settings.instance_eval("output_directory_#{platform}")}css/application.css"
          end
      end
    end
  end

  FileUtils.rm_rf App.settings.output_directory
end

require "zake"
BetaBuilder::Tasks.new do |config|

  config.configuration = "Release"
  config.build_dir = "ios/DerivedData/DonegalIOS/Build/Products"
  config.workspace_path = "ios/DonegalIOS.xcworkspace"
  config.scheme = "DonegalIOS"
  config.app_name = "DonegalIOS"

end

namespace :xbuild do
  desc "Unlcok keychain"
  task :unlock_keychain do
    `security unlock-keychain -p 12344321 /Users/jenkins/Library/Keychains/login.keychain`
  end

  desc "Update build version"
  task :update_build_version do
    git_version = `git describe`
    puts "git_version:#{git_version}"
    components = git_version.split("-")
    app_version = components[0] || "0"
    build_version = components[1] || "0"
    puts "app_version:#{app_version}; build_version:#{build_version}"

    files = `ls ios/`.split(/\n/)   

    workspace_name = files.select{|e| e =~ /.*\.xcodeproj/}.last.gsub(".xcworkspace", "")
    plist_name = "ios/DonegalIOS/DonegalIOS-Info.plist"
    `/usr/libexec/PlistBuddy -c "Set CFBundleVersion #{build_version}" #{plist_name}`
    `/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString #{app_version}" #{plist_name}`
  end

  desc "Build project"
  task :build_project => [:update_build_version, :unlock_keychain, "beta:package"]  do
  end
end

begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end
