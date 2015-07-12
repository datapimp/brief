class Brief::Apps::Blueprint::Epic
  include Brief::Model
  include Brief::RemoteSyncing

  defined_in Pathname(__FILE__)

  meta do
    title
    subheading
    project
    owner
    status String, :in => %w(draft published)
    tags Array
  end

  content do
    title "h1:first-of-type"
    paragraph "p:first-of-type"
    paragraphs "p"

    define_section "Features" do
      each("h2").has(:title     => "h2",
                     :paragraph => "p:first-of-type",
                     :components   => "p:first-of-type strong",
                     :tasks => "ul li"
                    )

      each("h2").is_a :feature
    end
  end

  template <<-EOF
# <%= object.title %>
# Features
<% Array(object.features).each do |feature| %>
## <%= feature.title %>
<%= feature.paragraph %>
<% end %>
  EOF


  actions do
    def validate
      $brief_cli ? validate_cli : true
    end

    def estimate
      estimate_cli if $brief_cli
    end

    def activate
      raise 'Need to implement this on your own'
    end

    def publish
      BlueprintEpicPublisher.publish(self, via: briefcase.settings.try(:tracking_system))
    end

    # Converts a draft epic which contains inline feature definitions
    # into individual feature files
    def featurize
      puts "== Generating features for #{ title }"

      features_data.each do |feature|
        puts "    -- #{ feature.title }"

        begin
          generate_feature(feature.title) if feature.title
        rescue => e
          puts "Error generating feature: #{ feature.title } #{ e.message }".red
        end
      end

      nil
    end
  end

  helpers do
    def features
      briefcase.features(project: project, epic: title)
    end

    def active?
      status.to_s.downcase == "active"
    end

    def published?
      status.to_s.downcase == "published"
    end

    def draft?
      status.to_s.downcase == "draft" || status.to_s == ""
    end

    def parent_project
      briefcase.projects(project: project).first
    end

    def find_feature_by_title(feature_title)
      briefcase.features(project: project, epic: title, title: feature_title)
    end

    def features_data
      sections.features.items.map do |item|
        item.components = Array(item.components)

        item.merge(goal: item.components[2],
                   persona: item.components[0],
                   behavior: item.components[1])

      end
    end

    def generate_feature(feature_heading)
      path = feature_file_for(feature_heading)
      FileUtils.mkdir_p(path.dirname)

      c = generate_feature_content(feature_heading)

      path.open("w+") do |fh|
        fh.write(c)
      end
    end

    def generate_feature_content(feature_heading)
      if feature_file_for(feature_heading).exist?
        return feature_file_for(feature_heading).read
      end

      data = {
        status: status,
        project: project,
        epic: title,
        title: feature_heading
      }

      content = raw_content_for_feature(feature_heading)

      data.stringify_keys.to_yaml + "---\n\n" + content
    end

    def feature_file_for(feature_heading)
      folder = features_folder
      filename = feature_heading.strip.parameterize + '.md'
      folder.join(filename)
    end

    def features_folder
      briefcase.docs_path.join("features", project.parameterize, title.parameterize)
    end

    def raw_content_for_feature(feature_heading, include_heading=true)
      document.content_under_heading(feature_heading, include_heading).tap do |v|

        # UGLY
        # Promotes the h2 heading to an h1 for this document
        v.gsub! "## #{ feature_heading }", "# #{ feature_heading }"
        v.gsub! "###{ feature_heading }", "# #{ feature_heading }"
      end
    end

    def estimate_cli
      new_content = ask_editor("# Enter point values next to each feature title\n\n#{estimations_yaml}")
      parsed      = YAML.load(new_content) rescue nil

      if parsed
        estimations_yaml_path.open("w+") {|fh| fh.write(new_content) }
      end
    end

    def estimations_yaml
      estimations_data.to_yaml
    end

    def estimations_data
      if estimations_yaml_path.exist?
        YAML.load(estimations_yaml_path.read)
      else
        estimates = features.map(&:title).reduce({}) do |memo, feature_title|
          memo[feature_title] = 0
          memo
        end

        {
          type: "epic_estimations",
          document_path: document.path,
          epic_title: title,
          estimates: estimates
        }.stringify_keys
      end
    end

    def estimations_yaml_path
      briefcase.data_path.join("estimations","#{title.parameterize}.yml")
    end

    # prints a validation report of the epic
    def validation_report
      warnings = []
      errors = []

      begin
        if features.any? {|f| f.title.to_s.length == 0 }
          errors.push "Feature is missing title. Should be an h2 element"
        end
      rescue => e
        errors.push "Error generating features: #{ e.message }"
      end

      if title.to_s.length == 0
        errors.push "Missing epic title"
      end

      if project.to_s.length == 0
        warnings.push "Missing project reference"
      else
        project_titles = Array((briefcase.projects.map(&:title) rescue nil))
        warnings.push "Invalid project reference. #{ project } does not refer to a valid project. #{ project_titles }" unless project_titles.include?(project)
      end

      [warnings, errors]
    end

    def validate_cli
      warnings, errors = validation_report

      if !warnings.empty?
        puts "== Epic Warnings. #{ document.path }".yellow
        warnings.each {|w| puts "  -- #{ w }" }
      end

      if !errors.empty?
        puts "== Epic Errors. #{ document.path }".red
        errors.each {|w| puts "  -- #{ w }" }
      end
    end

    def github_issue_body
      replace_feature_content_with_issue_links
    end

    def github_issue_title
      title
    end

    def replace_feature_content_with_issue_links
      content
    end

    def github_issue_labels
      []
    end

    def github_milestone_number
      nil
    end

    def github_issue_attributes
      {
        title: github_issue_title,
        body: github_issue_body,
        labels: github_issue_labels,
        milestone: github_milestone_number
      }
    end

  end
end
