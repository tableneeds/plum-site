# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "controllers", to: "controllers/index.js"
pin "controllers/application", to: "controllers/application.js"
pin "controllers/hello_controller", to: "controllers/hello_controller.js"

# Plum 0.2.0's controller directory does not expand in an external host's
# import map. Pin the packaged files explicitly until the upstream path fix is
# available in a released gem.
Plum::Engine.root.join("app/javascript/controllers/plum").glob("*_controller.js").sort.each do |controller|
  pin "controllers/plum/#{controller.basename(".js")}", to: "plum/#{controller.basename}"
end
