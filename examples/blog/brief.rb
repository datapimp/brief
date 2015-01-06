# configuration options for this briefcase
config do
  set(:models_path => Pathname(__FILE__).parent.join("models"))
end

# define a Post model
define("Post") do

  # the post model will have YAML frontmatter
  # with values for 'status' and 'date'
  meta do
    status
    date DateTime, :default => lambda {|post, attr| post.document.created_at }
  end

  # the post model will have a 'title' method which returns the text
  # from the first h1 heading
  content do
    title "h1"
    has_many :subheadings, "h2"
  end

  helpers do
    def publish(options={})

    end
  end

  # Whenever we call post.save() and the status attribute changes
  # from draft to published, do something with the model
  on_status_change(:from => "draft", :to => "published") do |model|
    # Do Something
    # mail_service.send_html_email_campaign(model.to_html)
  end
end

# this creates a custom command in the brief CLI tool
#
# so when you run:
#
#   brief publish posts /path/to/*.html.md.
#
# the brief CLI will find models for the post files you reference,
# and call whatever methods you want.

action "publish posts" do |briefcase, models, options|

  say "== Publishing #{ models.length } posts"

  Array(models).each do |post|
    post.publish()
  end
end

