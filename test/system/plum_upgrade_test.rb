require "application_system_test_case"

class PlumUpgradeTest < ApplicationSystemTestCase
  setup do
    load Rails.root.join("db/seeds.rb")
  end

  test "released Plum renders the site and current blueprint editor" do
    visit "/"
    assert_text "Give Rails an editor."

    visit "/login"
    fill_in "Email", with: "admin@plumcms.org"
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_text "Dashboard"

    click_link "New Type"
    wait_for_blueprint_controller
    unless page.has_css?("[data-plum--blueprint-target='field']", wait: 5)
      browser_messages = page.driver.browser.logs.get(:browser).map(&:message)
      flunk "Blueprint controller did not respond. Browser console:\n#{browser_messages.join("\n")}"
    end

    within("[data-plum--blueprint-target='field']") do
      find("[data-field='handle']").fill_in with: "team"
      find("[data-field='type']").select "Repeater"
      assert_selector "[data-field='min_items']"
      assert_button "Add nested field"
    end
  end

  private

  def wait_for_blueprint_controller
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        click_button "Add Field"
        break if page.has_css?("[data-plum--blueprint-target='field']", wait: 0.25)
      end
    end
  end
end
