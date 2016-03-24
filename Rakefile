FACTORIO_VERSION = File.read("VERSION").chomp

task default: %w[tag]

desc "Update Version"
task :update_version do
  dockerfile = File.read('Dockerfile')
  dockerfile.gsub('0.12.29', FACTORIO_VERSION)
  File.open('Dockerfile', 'w') {|of|
    of.write dockerfile
  }
  puts "Wrote dockerfile for version #{FACTORIO_VERSION}"
end

desc "Build skord/factorio:latest"
task :build => :update_version do
  system("docker build -t skord/factorio:latest .")
end

desc "Tag skord/factorio:latest with current factorio headless version"
task :tag => :build do
  system("git tag #{FACTORIO_VERSION}")
  puts "Wrote git tag"
  system("docker tag skord/factorio:latest skord/factorio:#{FACTORIO_VERSION}")
  puts "Wrote docker tag"
end

desc "Push to docker hub and github"
task :publish => :tag do
  system("git push origin --tags")
  system("docker push skord/factorio")
end

desc "Seed and run the server, no persistence, remove container on exit"
task :quick_server => :tag do
  system("docker run -it --rm -e SEED_SERVER=true --name factorio -net bridge -p 34197:34197/udp skord/factorio:#{FACTORIO_VERSION} /opt/factorio/bin/x64/factorio --start-server savegame")
end
