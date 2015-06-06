command "show app" do |c|
  c.syntax = "brief edit app NAME"
  c.description = "edit a brief app"

  c.action do |args, options|
    app = args.first.to_s.downcase

    if Brief::Apps.available?(app)
      puts "#{ Brief::Apps.path_for(app) }"
    end
  end
end


