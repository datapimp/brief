command 'init' do |c|
  c.syntax = 'brief init NAME [OPTIONS]'
  c.description = 'Create a new brief project, aka a briefcase'

  c.option '--root', String, 'The root folder for the new project.'

  c.action do |args, options|
    options.default(root: Dir.pwd)

    if path = args.first
      root = Pathname(options.root).join(path)
    end

    [root, root.join('models'), root.join('docs')].each do |p|
      puts "== folder #{ p.basename } #{ '. exists' if p.exist? }"
      FileUtils.mkdir_p(p) unless p.exist?
    end

    if root.join('brief.rb').exist?
      say '== Briefcase config already exists. Skipping.'
    else
      say '== Creating config file brief.rb'
      root.join('brief.rb').open('w+') do |fh|
        default_config = <<-EOF

config do
  set(:models_path => Pathname(__FILE__).parent.join("models"))
end

define("Post") do
  meta do
    status
    date DateTime, :default => lambda {|post, attr| post.document.created_at }
  end

  content do
    title "h1"
    has_many :subheadings, "h2"
  end

  helpers do
    def publish(options={})
      post.set(:status, "published")
      post.save
    end
  end

  on_status_change(:from => "draft", :to => "published") do |model|
    # Do Something
    # mail_service.send_html_email_campaign(model.to_html)
  end
end

# brief publish posts /path/to/*.html.md
action "publish posts" do |briefcase, models, options|
  models.each do |post|
    post.publish(options)
  end
end
        EOF
        fh.write(default_config)
      end
    end
  end
end
