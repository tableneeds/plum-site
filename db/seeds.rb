admin = Plum::User.find_or_initialize_by(email: ENV.fetch("PLUM_ADMIN_EMAIL", "admin@plumcms.org"))
development_password = Rails.env.production? ? ENV.fetch("PLUM_ADMIN_PASSWORD") : "password"
admin.password = development_password
admin.role = :admin
admin.save!

site = Plum::Site.first_or_create_standalone!
site.update!(
  name: "Plum",
  theme_name: "plum",
  theme_settings: { "github_url" => "https://github.com/tableneeds/plum" }
)

Plum::SiteSetting.instance(site).update!(
  name: "Plum",
  tagline: "The Rails-native CMS",
  seo_title: "Plum — The Rails-native CMS",
  seo_description: "Add managed content to an existing Rails application or build a complete content-first site without leaving the Rails stack.",
  theme_name: "plum",
  primary_color: "#6d285f",
  support_email: "hello@plumcms.org"
)

pages = site.content_types.find_or_initialize_by(handle: "pages")
pages.update!(
  name: "Pages",
  icon: "page",
  blueprint: {
    "fields" => [
      { "handle" => "summary", "type" => "textarea", "label" => "Summary" },
      { "handle" => "body", "type" => "rich_text", "label" => "Body" },
      { "handle" => "sections", "type" => "blocks", "label" => "Sections" }
    ]
  }
)

docs = site.content_types.find_or_initialize_by(handle: "docs")
docs.update!(
  name: "Documentation",
  icon: "document",
  blueprint: {
    "route_prefix" => "docs",
    "fields" => [
      { "handle" => "summary", "type" => "textarea", "label" => "Summary" },
      { "handle" => "section", "type" => "select", "label" => "Section", "options" => [ "Start", "Concepts", "Build", "Operate" ] },
      { "handle" => "position", "type" => "text", "label" => "Position" },
      { "handle" => "body", "type" => "rich_text", "label" => "Body" }
    ]
  }
)

home = site.entries.find_or_initialize_by(slug: "home")
home.update!(
  content_type: pages,
  author: admin,
  title: "Home",
  status: :published,
  published_at: Time.current,
  data: {
    "summary" => "The Rails-native CMS.",
    "sections" => [
      {
        "id" => SecureRandom.uuid,
        "type" => "hero",
        "fields" => {
          "heading" => "Give Rails an editor.",
          "subheading" => "Plum is the conventional content layer for Rails. Mount it when you already have an application. Start with it when content is the application.",
          "button_label" => "Get started",
          "button_url" => "/docs/getting-started"
        }
      },
      {
        "id" => SecureRandom.uuid,
        "type" => "product_demo",
        "fields" => {
          "eyebrow" => "See the whole loop",
          "heading" => "Define it once. Edit it clearly. Render it anywhere.",
          "introduction" => "A Plum content type becomes an editor for people and structured data for the Rails application. No API synchronization sits between them."
        }
      },
      {
        "id" => SecureRandom.uuid,
        "type" => "feature_grid",
        "fields" => {
          "eyebrow" => "From model to published page",
          "heading" => "Content management without leaving the framework.",
          "introduction" => "Plum turns the Rails conventions you already trust into a complete editorial workflow.",
          "first_title" => "Model",
          "first_text" => "Define structured content with content types, familiar fields, relationships, taxonomies, and reusable blocks.",
          "second_title" => "Edit",
          "second_text" => "Give editors a focused Hotwire control panel backed by your database, storage, jobs, users, and authorization.",
          "third_title" => "Render",
          "third_text" => "Publish through portable Liquid themes, or expose managed content wherever the host Rails application needs it."
        }
      },
      {
        "id" => SecureRandom.uuid,
        "type" => "code_example",
        "fields" => {
          "eyebrow" => "Not a second application",
          "heading" => "Your Rails app remains the source of truth.",
          "text" => "Plum uses host identity and authorization, while content sources make application data available to editors and themes without copying it into another CMS.",
          "code" => <<~RUBY.chomp,
            Plum.configure do |config|
              config.current_site_resolver = ->(_) { Current.account.plum_site }
              config.current_user_resolver = ->(_) { Current.user }

              config.register_content_source :products do |context|
                context.owner.products.published
              end
            end
          RUBY
          "caption" => "Ordinary Ruby configuration. No synchronization webhooks."
        }
      },
      {
        "id" => SecureRandom.uuid,
        "type" => "feature_grid",
        "fields" => {
          "eyebrow" => "Start from either side",
          "heading" => "One content system, two natural Rails workflows.",
          "introduction" => "Plum is an engine when content joins an application and a foundation when content comes first.",
          "first_title" => "Existing application",
          "first_text" => "Mount the engine. Keep the host's users, policies, routes, records, and deployment. Add only the editorial layer you need.",
          "second_title" => "Content-first site",
          "second_text" => "Begin with Rails, Plum, SQLite, and a theme. Add ordinary models and controllers when the site grows into an application.",
          "third_title" => "Agency fleet",
          "third_text" => "Run independent client sites as portable containers with separate SQLite databases, assets, domains, and backups on one VM."
        }
      },
      {
        "id" => SecureRandom.uuid,
        "type" => "cta",
        "fields" => {
          "heading" => "Keep content in Rails.",
          "text" => "Give editors what they need while keeping the application simple, portable, and entirely yours.",
          "button_label" => "Read the getting-started guide",
          "button_url" => "/docs/getting-started"
        }
      }
    ]
  }
) if home.new_record? || home.data.fetch("sections", []).blank?

why_plum = site.entries.find_or_initialize_by(slug: "why-plum")
why_plum.update!(
  content_type: pages,
  author: admin,
  title: "Why Plum",
  status: :published,
  published_at: Time.current,
  data: {
    "summary" => "Managed content should feel like a native capability of a Rails application.",
    "body" => <<~HTML
      <p>Rails is excellent at building applications, but content management is still commonly assembled from bespoke admin screens or delegated to a remote service. Both choices create work that does not improve the final site.</p>
      <h2>Keep the application whole</h2>
      <p>Plum uses the host application's database, users, authorization, jobs, mail, storage, and deployment. Developers retain ordinary Ruby extension points while editors receive a focused place to work.</p>
      <h2>Start small without choosing a dead end</h2>
      <p>A content site can begin with Rails and SQLite on one VM. The same content model can live inside a larger PostgreSQL application when the project calls for it.</p>
      <h2>Own the result</h2>
      <p>Plum is open source and self-hosted. A site should remain portable as code, structured content, assets, and a documented backup—not as an account on somebody else's platform.</p>
    HTML
  }
) if why_plum.new_record?

roadmap = site.entries.find_or_initialize_by(slug: "roadmap")
roadmap.update!(
  content_type: pages,
  author: admin,
  title: "Roadmap",
  status: :published,
  published_at: Time.current,
  data: {
    "summary" => "Plum's roadmap is organized around useful outcomes rather than promised dates.",
    "body" => <<~HTML
      <h2>Now: make Plum adoptable</h2>
      <p>Build this site with Plum, publish the gem, document the current product, and prove a portable Rails and SQLite deployment with dependable backups.</p>
      <h2>Next: editorial confidence</h2>
      <p>Add preview, revisions, rollback, scheduled publishing, multi-entry relationships, reusable sections, and complete content export and restore workflows.</p>
      <h2>Later: a Rails content ecosystem</h2>
      <p>Develop a thin Plum CLI, starter applications, extension contracts, and a collection of excellent themes and blocks for Rails developers and agencies.</p>
      <h2>Plum 1.0</h2>
      <p>Another Rails developer can reproduce what powers this site without private knowledge, special patches, or a second application stack.</p>
    HTML
  }
) if roadmap.new_record?

documentation = [
  {
    slug: "getting-started",
    title: "Getting started",
    section: "Start",
    summary: "Install Plum and publish your first editable page.",
    body: <<~HTML
      <p>Plum is a mountable Rails engine. During development, add it from a local path or Git source.</p>
      <pre><code>gem "plum", path: "../Plum"</code></pre>
      <p>Install the engine, Active Storage tables, and database schema:</p>
      <pre><code>bundle install
bin/rails generate plum:install --mount-path=/
bin/rails active_storage:install
bin/rails db:migrate</code></pre>
      <p>The public site is now available at <code>/</code>, with the control panel at <code>/cp</code>. The generated initializer contains the standalone defaults and examples for embedding Plum in a host application.</p>
      <h2>Choose a theme</h2>
      <p>Host themes live under <code>app/themes</code>. Set the site's theme handle, create a Pages content type, and publish an entry with the reserved <code>home</code> slug to control the homepage.</p>
    HTML
  },
  {
    slug: "core-concepts",
    title: "Core concepts",
    section: "Concepts",
    summary: "Understand sites, content types, entries, fields, and themes.",
    body: <<~HTML
      <h2>Sites</h2><p>Every content-bearing record belongs to a Plum site. Standalone applications normally use one implicit site; embedded applications can resolve one site per host account.</p>
      <h2>Content types</h2><p>A content type defines a reusable blueprint. Its fields describe the structured data editors can manage.</p>
      <h2>Entries</h2><p>Entries are instances of content types. They have a title, slug, publication status, publication time, and blueprint-backed data.</p>
      <h2>Themes</h2><p>Themes provide Liquid layouts, templates, assets, configurable settings, and block definitions. Host application themes take precedence over Plum's bundled fallbacks.</p>
    HTML
  },
  {
    slug: "themes-and-liquid",
    title: "Themes and Liquid",
    section: "Build",
    summary: "Create portable presentation layers with Liquid templates and blocks.",
    body: <<~HTML
      <p>A theme starts with <code>theme.yml</code>, a base layout, and Liquid templates. Themes can be bundled with the application or installed from a validated zip package.</p>
      <pre><code>app/themes/my-theme/
  theme.yml
  layouts/base.liquid
  templates/index.liquid
  templates/entries/pages.liquid
  assets/theme.css</code></pre>
      <h2>Liquid context</h2><p>Templates receive the current site and entry along with entries grouped by content type, navigation menus, globals, taxonomies, forms, and registered host content sources.</p>
      <h2>Blocks</h2><p>Plum includes a small universal block palette. Themes may add blocks or override a base block by reusing its handle and providing a matching Liquid partial.</p>
    HTML
  },
  {
    slug: "embedding-plum",
    title: "Embedding Plum",
    section: "Build",
    summary: "Connect Plum to an existing application's identity, tenancy, and data.",
    body: <<~HTML
      <p>Mount the engine at the path that fits the host application, then configure resolvers for the current site and user.</p>
      <pre><code>Plum.configure do |config|
  config.current_site_resolver = ->(_) { Current.account.plum_site }
  config.current_user_resolver = ->(_) { Current.user }
  config.authorize_with = :host
  config.host_authorization_resolver = ->(_) { Current.user.admin? }
end</code></pre>
      <p>The host owns authorization. Plum keeps every content query site-scoped and uses registered content sources to expose application data to Liquid without copying it.</p>
    HTML
  },
  {
    slug: "deployment",
    title: "Deployment",
    section: "Operate",
    summary: "Run a self-contained Plum site with Rails, SQLite, and persistent storage.",
    body: <<~HTML
      <p>A small Plum site can run as one Rails container backed by SQLite. Persist the database and Active Storage files together, take consistent backups, and keep the application image replaceable.</p>
      <h2>Agency model</h2><p>Use one independent container and data volume per client. Multiple sites can share a VM through an application server such as ONCE while retaining separate domains, upgrades, backups, and ownership.</p>
      <h2>Larger applications</h2><p>Plum avoids database-specific JSON queries and also supports PostgreSQL for embedded and higher-scale deployments.</p>
    HTML
  }
]

doc_entries = documentation.map.with_index do |attributes, index|
  entry = site.entries.find_or_initialize_by(slug: attributes.fetch(:slug))
  defaults = {
    "summary" => attributes.fetch(:summary),
    "section" => attributes.fetch(:section),
    "position" => (index + 1).to_s,
    "body" => attributes.fetch(:body)
  }
  if entry.new_record?
    entry.update!(
      content_type: docs,
      author: admin,
      title: attributes.fetch(:title),
      status: :published,
      published_at: Time.current,
      data: defaults
    )
  else
    merged_data = defaults.merge(entry.data || {})
    entry.update!(data: merged_data) if merged_data != entry.data
  end
  entry
end

main_nav = site.nav_menus.find_or_initialize_by(handle: "main")
main_nav.update!(name: "Main navigation")
[
  [ "Why Plum", why_plum, nil ],
  [ "Documentation", nil, "/docs" ],
  [ "Roadmap", roadmap, nil ],
  [ "GitHub", nil, "https://github.com/tableneeds/plum" ]
].each_with_index do |(label, entry, url), index|
  item = main_nav.nav_items.find_or_initialize_by(label: label)
  item.update!(site: site, entry: entry, url: url, position: index + 1, parent: nil)
end

docs_nav = site.nav_menus.find_or_initialize_by(handle: "docs")
docs_nav.update!(name: "Documentation navigation")
doc_entries.each_with_index do |entry, index|
  item = docs_nav.nav_items.find_or_initialize_by(label: entry.title)
  item.update!(site: site, entry: entry, url: nil, position: index + 1, parent: nil)
end

puts "Seeded Plum marketing site"
puts "Control panel: http://localhost:3000/cp"
puts "Development login: #{admin.email} / password" unless Rails.env.production?
