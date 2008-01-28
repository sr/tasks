namespace :omni do
  task :blogify => ['blogify:entries', 'blogify:index']
  namespace :blogify do
    %w(rubygems rake atom/collection atom/http haml).each { |l| require l }
    PUB_PATH = File.expand_path(ENV['PUB_PATH'] || File.dirname(__FILE__))
    TEMPLATE = File.expand_path(ENV['TEMPLATE'] || File.dirname(__FILE__) + '/template.haml')

    task :entries => :retrieve_entries do
      template = Haml::Engine.new(File.read(TEMPLATE))
      ENTRIES.each do |month, entries|
        FileUtils.mkdir_p("#{PUB_PATH}/#{entries.first.updated.year}")
        file = "#{PUB_PATH}/#{month}.html"
        unless File.exists?(file) && "#{Time.now.year}/#{Time.now.strftime('%m')}" != month
          File.open(file, 'w') { |f| f << template.render(binding) }
        end
      end
    end

    task :index => :entries do
      cp PUB_PATH + "/#{ENTRIES.keys.sort.pop}.html", PUB_PATH + '/index.html'
      archives = '<div id="archives"><ul>%s</ul></div>' % 
        ENTRIES.keys.map{|m|"<li><a href=\"#{m}.html\">#{m}</a></li>"}.join("\n")
      content = File.read(PUB_PATH + '/index.html')
      File.open(PUB_PATH + '/index.html', 'w'){|f| f << content.gsub('</h1>', "</h1>\n"+archives)}  
    end

    task :retrieve_entries do
      http = Atom::HTTP.new
      if ENV['LOGIN'] && ENV['PASS']
        http.user = ENV['LOGIN']
        http.pass = ENV['PASS']
      end
      collection = Atom::Collection.new(ENV['URI'], http)
      collection.update!
      raise 'collection is empty' if collection.entries.empty?
      collection.entries.sort_by { |e| e.updated }
      ENTRIES = collection.entries.inject({}) do |hash, entry|
        key = "#{entry.updated.year}/#{entry.updated.strftime('%m')}"
        hash.merge({key => (hash[key] || []) << entry})
      end unless defined?(ENTRIES)
    end
  end
end
