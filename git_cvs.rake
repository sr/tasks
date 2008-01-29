namespace :git do
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
