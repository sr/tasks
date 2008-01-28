namespace :atompub do
  desc 'Publish FILE or STDIN to the Atom collection located at URI. You can specify LOGIN and PASS if the collection is protected.'
  task :publish do
    %w(rubygems rake atom/collection atom/yaml maruku rubypants).each { |l| require l }
    yaml = (ENV['FILE'] && File.exists?(ENV['FILE'])) ? File.read(ENV['FILE']) : STDIN.read
    http = Atom::HTTP.new
    if ENV['LOGIN'] && ENV['PASS']
      http.user = ENV['LOGIN']
      http.pass = ENV['PASS']
    end
    collection = Atom::Collection.new(ENV['URI'], http)
    entry = Atom::Entry.from_yaml(yaml)
    entry.content = Maruku.new(RubyPants.new(entry.content.to_s).to_html).to_html if ENV['HTMLIZE']
    entry.content['type'] = ENV['CONTENT_TYPE'] || 'xhtml'
    response = collection.post!(entry, ENV['SLUG'] || yaml['slug'])
    puts response.code.to_i == 201 ? 
      "Ok, entry created. Location: #{Atom::Entry.parse(response.body).edit_url}" :
      "Oops, something went wrong. #{response.code} - #{response.message}"
  end
end
