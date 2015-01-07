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

  actions do
    def publish(options={})
      puts "The publish action"
    end
  end
end
