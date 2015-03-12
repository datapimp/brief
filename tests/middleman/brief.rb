dir = Pathname(File.dirname(__FILE__))

config do
  set(:docs_path, dir.join("documents"))
end

define "Page" do
  meta do
    title
  end

  content do
    title "h1:first-of-type"
    paragraphs "p"
  end
end
