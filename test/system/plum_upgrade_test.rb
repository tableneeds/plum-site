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

    within("[data-plum--blueprint-target='field']") do
      find("[data-field='handle']").fill_in with: "team"
      find("[data-field='type']").select "Repeater"
      assert_selector "[data-field='min_items']"
      assert_button "Add nested field"
    end
  end

  private

  def wait_for_blueprint_controller
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 10
    loop do
      click_button "Add Field"
      return if page.has_css?("[data-plum--blueprint-target='field']", wait: 0.25)
      break if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline
    end

    browser_messages = page.driver.browser.logs.get(:browser).map(&:message)
    flunk "Blueprint controller did not respond. Browser console:\n#{browser_messages.join("\n")}"
  end
end
