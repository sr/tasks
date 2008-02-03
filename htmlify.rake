namespace :atonie do
  desc 'Convert *.text to their *.html equivalent and gitignore them'
  task :htmlify do
    %w(rubygems maruku maruku/string_utils rubypants).each { |l| require l }
    include MaRuKu::Strings
    ENV['IGNORE']     ||= '/2006\/wiki|itquote/'
    ENV['GIT_IGNORE'] ||= '.gitignore'
    template = File.read(__FILE__).gsub(/.*__END__/m, '')
    Dir['*.text', '*/*.text', '*/*/*.text'].each do |file|
      next if file =~ Regexp.new(ENV['IGNORE'])
      file = File.join(ENV['PWD'], file.gsub('./', '').chomp)
      source = File.read(file)
      destination = file.gsub('.text', '.html')
      File.open(destination, 'w') do |f|
        puts "Converting #{file} to #{f.path}\n"
        parsed = parse_email_headers(source)
        f << template % [parsed[:title], Maruku.new(RubyPants.new(parsed[:data]).to_html).to_html]
      end
      FileUtils.touch(ENV['GIT_IGNORE']) unless File.exists?(ENV['GIT_IGNORE'])
      unless File.readlines(ENV['GIT_IGNORE']).map{|l| l.chomp}.include?(destination.gsub!(ENV['PWD']+'/', ''))
        puts "Ignoring #{file}\n"
        File.open(ENV['GIT_IGNORE'], 'a') { |f| f << destination+"\n" }
      end
    end
  end
end
__END__
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
  "http://www.w3.org/TR/html4/strict.dtd">
<html>
  <head><title>%s</title></head>
  <body>
    %s
  </body>
</html>
