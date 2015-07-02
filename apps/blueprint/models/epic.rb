class Brief::Apps::Blueprint::Epic
  include Brief::Model

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
  end

  helpers do
    def features
      sections.features.items.map do |item|
        item.components = Array(item.components)

        item.merge(goal: item.components[2],
                   persona: item.components[0],
                   behavior: item.components[1])

      end
    end

    def raw_content_for_feature(feature_heading, include_heading=true)
      document.content_under_heading(feature_heading, include_heading)
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
        features
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
  end
end
