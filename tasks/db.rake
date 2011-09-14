
namespace :db do

  $: << File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

  desc "Initialize the database model" 
  task :init => [:auto_upgrade!]

  desc "Run DataMapper.auto_upgrade! (non-destructively applies model schema)"
  task :auto_upgrade! do

    require 'ptj/default_setup'
    DataMapper.auto_upgrade!
    puts "Database initialized"
  end
  
  desc "Dump db record counts with debugging"
  task :count do
    require 'ptj/default_setup'
    time_now = Time.now
    puts "Passwords:   #{PTJ::Password.count}"
    puts "Tags:        #{PTJ::Tag.count}"
    puts "Time Taken: #{Time.now - time_now} seconds."
  end

  desc "Backup the development database"
  task :backup do
    require 'date'
    tarfile = DateTime.now.strftime("data/data-%F.%H.%M.%S.%2N.tar.bz2")
    sh "tar -cjvf #{tarfile} data/ptj.db"
    puts "* Backed up data in: #{tarfile}"
  end

  desc "Destructively re-initialize the default db setup (no backup)"
  task :reinit! => [:clobber_db, :init]

  desc "Less destructively re-initialize the default db setup with a backup" 
  task :reinit => [:backup, :clobber, :init]

  desc "Clobber the development database"
  task :clobber_db do
    require 'ptj/default_setup'
    require 'pathname'
    require 'addressable/uri'

    db_conn = PTJ::Env::CONFIG['db_conn']
    if( db_conn.is_a?(String) and 
        (u=Addressable::URI.parse(db_conn)).scheme == 'sqlite' and
        (path=Pathname.new(u.path)).file? )
      sh "rm -f #{path}"
    end
  end

  desc "Run DataMapper.auto_migrate! (destructively creates model schema)"
  task :auto_migrate! do
    require 'ptj/default_setup'
    DataMapper.auto_migrate!
  end  
end
