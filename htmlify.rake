namespace :atonie do
  desc 'Convert *.text to their *.html equivalent and gitignore them'
  task :htmlify do
    %w(rubygems maruku rubypants).each { |l| require l }
    ENV['IGNORE']     ||= '/2006\/wiki|itquote/'
    ENV['GIT_IGNORE'] ||= '.gitignore'
    `find -name *.text`.each do |file|
      next if file =~ Regexp.new(ENV['IGNORE'])
      file = File.join(ENV['PWD'], file.gsub('./', '').chomp)
      source = File.read(file)
      destination = file.gsub('.text', '.html')
      File.open(destination, 'w') do |f|
        puts "Converting #{file} to #{f.path}\n"
        f << Maruku.new(RubyPants.new(source).to_html).to_html_document
      end
      FileUtils.touch(ENV['GIT_IGNORE']) unless File.exists?(ENV['GIT_IGNORE'])
      unless File.readlines(ENV['GIT_IGNORE']).map{|l| l.chomp}.include?(destination.gsub!(ENV['PWD']+'/', ''))
        puts "Ignoring #{file}\n"
        File.open(ENV['GIT_IGNORE'], 'a') { |f| f << destination+"\n" }
      end
    end
  end
end
