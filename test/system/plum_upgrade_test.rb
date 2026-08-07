require "application_system_test_case"

class PlumUpgradeTest < ApplicationSystemTestCase
  setup do
    load Rails.root.join("db/seeds.rb")
  end

  test "released Plum renders the site and current control panel" do
    visit "/"
    assert_text "Give Rails an editor."

    visit "/login"
    fill_in "Email", with: "admin@plumcms.org"
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_text "Dashboard"

    click_link "New Type"
    assert_text "New Content Type"
    assert_text "Choose fields and configure how editors enter content."
    assert_button "Add Field"
    assert_link "Manage reusable fieldsets"
    assert_selector "[data-controller='plum--blueprint']"
  end
end
