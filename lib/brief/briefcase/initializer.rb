class Brief::Briefcase
  class Initializer
    def initialize(options={})
      @options = options.to_mash
    end

    def run
      options = @options
      root    = options.root

      FileUtils.mkdir_p(root.join("docs","posts"))

      config = "use(#{options.app})\n" if options.app

      config = <<-EOF
      root = Pathname(Dir.pwd)

      config do
        # You can put any special brief configuration here
        # set(models_path: root.join('models')) if root.join('models').exist?
        # set(templates_path: root.join('templates')) if root.join('templates').exist?
        # set(docs_path: root.join('documents')) if root.join('documents').exist?
      end
      \n
      define "Post" do
        meta do
          title
          status :in => %w(draft published)
          tags Array
        end
        \n
        content do
          title "h1:first-of-type"
          subheading "h2:first-of-type"
        end
      end
      EOF

      example = <<-EOF
      ---
      type: post
      title: This is my first post
      status: published
      tags:
        - default
        - intro
      ---

      # This is my first post

      I should write something clever.
      EOF

      config.gsub!(/^\ {1,6}/m, '')
      example.gsub!(/^\ {1,6}/m, '')

      root.join("docs","posts","this-is-my-first-post.md").open("w+") {|fh| fh.write(example) }

      root.join("brief.rb").open("w+") do |fh|
        fh.write(config)
      end
    end
  end
end
