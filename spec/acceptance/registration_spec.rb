require 'acceptance_helper'

feature "Person signs in" do
  let(:user) { Fabricate.build(:user) }
  let(:form) { find "form" }

  background do
    visit destroy_user_session_path
    visit root_path
  end

  scenario "with valid information" do
    click_link 'Sign up'

    form.fill_in "user_email", with: user.email
    form.fill_in "user_password", with: user.password
    form.fill_in "user_password_confirmation", with: user.password

    click_button "Sign up"

    page.should have_content "You have signed up successfully."
  end
end