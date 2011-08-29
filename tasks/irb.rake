
desc "Open an irb session preloaded with PTJ"
task :irb do
  sh "irb -rubygems -I lib -I PTJ -r ptj/default_setup"
end



