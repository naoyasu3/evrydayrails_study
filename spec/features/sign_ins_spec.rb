require 'rails_helper'

RSpec.feature "SignIns", type: :feature do
  let(:user) { FactoryBot(:user) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  scenatio "ユーザのログイン" do
    vist root_path
    click_link "Sign in"
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Log in"

    expect {
      GeocodeUser.perform_later(user)
    }.to have_enqueued_job.with(user)
  end
end
