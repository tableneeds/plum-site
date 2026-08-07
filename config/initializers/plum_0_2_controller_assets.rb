# Plum 0.2.0 maps controller assets under `plum/`, so Propshaft must search
# from the parent controllers directory. Remove this compatibility path after
# upgrading to the first Plum release that includes the corrected engine path.
Rails.application.config.assets.paths << Plum::Engine.root.join("app/javascript/controllers")
