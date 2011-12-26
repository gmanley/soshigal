require 'acceptance_helper'

feature "Person signs in" do
  let(:user) { Fabricate(:confirmed_user) }
  let(:form) { find "form#login" }

  background do
    visit destroy_user_session_path
    visit root_path
  end

  scenario "with invalid credentials" do
    form.fill_in "user_email", with: "invalid@email.com"
    form.fill_in "user_password", with: "wrong"

    click_button "Sign in"

    page.should have_content "Invalid email or password"
  end

  scenario "with valid credentials" do
    form.fill_in "user_email", with: user.email
    form.fill_in "user_password", with: user.password

    click_button "Sign in"

    page.should have_content 'Signed in successfully.'
  end
end