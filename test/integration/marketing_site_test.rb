require "test_helper"

class MarketingSiteTest < ActionDispatch::IntegrationTest
  setup do
    reset!
    load Rails.root.join("db/seeds.rb")
  end

  test "homepage is rendered by the Plum theme from editable content" do
    get "/"

    assert_response :success
    assert_select "title", text: /Plum/
    assert_select ".hero h1", count: 1
    assert_select ".hero .plumb-line[aria-hidden='true'] img[src*='plum-bob.svg']"
    assert_select ".site-header .wordmark img[src*='plum-mark.svg']"
    assert_select ".feature-grid article", minimum: 3
    assert_select ".header-action[href='/docs/getting-started']"
    assert_select "a[href='https://github.com/tableneeds/plum']", minimum: 1
  end

  test "documentation collection and articles are public" do
    get "/docs"

    assert_response :success
    assert_select "h1", text: "Documentation"
    assert_select "a[href='/docs/getting-started']"

    get "/docs/getting-started"

    assert_response :success
    assert_select ".docs-sidebar"
    assert_select ".docs-sidebar a[aria-current='page']", text: "Getting started"
    assert_select "h1", text: "Getting started"
    assert_select ".docs-toc a[href='#choose-a-theme']"
    assert_select ".doc-pagination a[href='/docs/core-concepts']"
    assert_select "pre code", text: /generate plum:install/
  end

  test "documentation search returns prefixed entry links" do
    get "/search", params: { q: "Getting" }

    assert_response :success
    assert_select ".search-results a[href^='/docs/']", minimum: 1
  end

  test "seeds do not overwrite editorial changes" do
    entry = Plum::Entry.find_by!(site: Plum::Site.first, slug: "why-plum")
    entry.update!(title: "A better reason")

    load Rails.root.join("db/seeds.rb")

    assert_equal "A better reason", entry.reload.title
  end

  test "control panel requires the Plum login" do
    get "/cp"

    assert_redirected_to "/login"

    follow_redirect!
    assert_select "title", text: "Login - Plum"
    assert_select "img[src*='plum-mark']"
    assert_select "h1", text: "Plum"
  end

  test "authenticated control panel renders all engine assets" do
    post "/login", params: {
      email: "admin@plumcms.org",
      password: "password"
    }

    assert_redirected_to "/cp"
    follow_redirect!
    assert_response :success
    assert_select "link[href*='lexxy'][rel='stylesheet']"
    assert_select "link[href*='plum/control_panel'][rel='stylesheet']"
    assert_includes response.body, "controllers/plum/blueprint_controller"
    assert Rails.application.assets.load_path.find("plum/blueprint_controller.js")
  end

  test "theme asset is served through Plum" do
    get "/theme_assets/plum/theme.css"

    assert_response :success
    assert_includes response.body, "--plum: #6d285f"
  end
end
