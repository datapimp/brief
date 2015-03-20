root = Pathname(Dir.pwd)

config do
  # You can put any special brief configuration here
  # set(models_path: root.join('models')) if root.join('models').exist?
  # set(templates_path: root.join('templates')) if root.join('templates').exist?
  # set(docs_path: root.join('documents')) if root.join('documents').exist?
end


define "Post" do
  meta do
    title
    status :in => %w(draft published)
    tags Array
  end
  

  content do
    title "h1:first-of-type"
    subheading "h2:first-of-type"
  end
end
