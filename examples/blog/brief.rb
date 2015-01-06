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
       puts "Publishing a post"
    end
  end

  on_status_change(:from => "draft", :to => "published") do |model|
    # Do Something
    # mail_service.send_html_email_campaign(model.to_html)
  end
end

# brief publish posts /path/to/*.html.md
action "publish posts" do |briefcase, models, options|

  say "== Publishing #{ models.length } posts"

  Array(models).each do |post|
    post.publish()
  end
end
