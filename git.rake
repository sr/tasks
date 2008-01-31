namespace :git do
  task :set_origin do
    ENV['SERVER'] ||= 'bearnaise.net'
    origin = "git@#{ENV['SERVER']}:#{ENV['NAME'] || File.basename(ENV['PWD'])}"
    puts "Adding origin #{origin}..." 
    `git remote add origin #{origin}`
  end

  task :push do
    ENV['NAME'] ||= File.basename(ENV['PWD'])
    `git push origin master:refs/heads/master`
    unless ENV['LOGIN'] && ENV['NAME']
      puts 'Not pushing to github'
      exit
    end
    push_url = "git@github.com:#{ENV['LOGIN']}/#{ENV['NAME']}"
    puts "Pushing to #{push_url}"
    `git push #{push_url} master`
  end

  namespace :cvs do
    task :init => :gitify do
      raise 'Missing LOGIN' unless ENV['LOGIN']
      raise 'Missing ADDR'  unless ENV['ADDR']
    end

    task :login do
      ENV['CVS_ROOT'] ||= 'cvs'
      puts "Signin in on #{ENV['ADDR']} as #{ENV['LOGIN']}..."
      `cvs -d :pserver:#{ENV['LOGIN']}@#{ENV['ADDR']}:/#{ENV['CVS_ROOT']} login`
    end

    task :checkout_cvs => :login do
      raise 'Missing MODULE' unless ENV['MODULE']
      puts "Checking out #{ENV['MODULE']} to #{File.join(ENV['PWD'], ENV['MODULE']+'.cvs')}..."
      `cvs -d :pserver:#{ENV['LOGIN']}@#{ENV['ADDR']}:/#{ENV['CVS_ROOT']} checkout #{ENV['MODULE']}`
      FileUtils.mv ENV['MODULE'], ENV['MODULE']+'.cvs'
    end

    task :gitify => :checkout_cvs do
      cvs_repo = ENV['MODULE']+'.cvs'
      FileUtils.cd File.join(ENV['PWD'], cvs_repo)
      git_repo = File.join(ENV['PWD'], cvs_repo.gsub('.cvs', '.git'))
      puts "Converting #{cvs_repo} to #{git_repo}..."
      `git-cvsimport -v -C ../#{git_repo} -a`
    end
  end
end
