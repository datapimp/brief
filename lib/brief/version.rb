
module Brief
  begin
    require 'git-version-bump'
    VERSION = GVB.version
  rescue
    VERSION = '1.17.8'
  end
end
