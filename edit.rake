namespace :edit do
  desc 'Sends STDIN or FILE=file to <http://edit.sunfox.org>'
  task :send do
    require 'uri'
    require 'net/http'

    name = ENV['FILE'] ? File.basename(ENV['FILE']) : ENV['PNAME'] || Time.now.to_i.to_s
    text = ENV['FILE'] ? File.read(File.expand_path(ENV['FILE'])) : STDIN.read 
    edit_url = ENV['EDIT_URL'] || 'http://edit.sunfox.org'
    page_url = URI.join(edit_url, name)

    response = Net::HTTP.post_form(page_url, {'text' => text})
    puts (response.code.to_i == 302) ? page_url : "Oops: #{response.message}" 
  end
end
