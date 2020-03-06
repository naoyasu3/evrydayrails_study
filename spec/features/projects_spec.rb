require 'rails_helper'

RSpec.feature "Projects", type: :feature do
  scenario "user creates a new project" do
    user = FactoryBot.create(:user)
    # using our customer login helper:
    # sign_in_as user
    # or the one provided by Devise:
    sign_in user

    visit root_path

    expect {
      click_link "New Project"
      fill_in "Name", with: "Test Project"
      fill_in "Description", with: "Trying out Capybara"
      click_button "Create Project"

      aggregate_failures do
        expect(page).to have_content "Project was successfully created"
        expect(page).to have_content "Test Project"
        expect(page).to have_content "Owner: #{user.name}"
      end
    }.to change(user.projects, :count).by(1)
  end

  scenario "ユーザはプロジェクトを完了済にする", focus: true do
    # プロジェクトを持ったユーザが必要
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project, owner: user)
    # ユーザはログインしている
    login_as user, scope: :user

    # ユーザがプロジェクト画面を開く
    visit project_path(project)

    expect(page).to_not have_content "Completed"

    # "complete"ボタンを押す
    click_button "Complete"
    # プロジェクトは完了済としてマークされる
    expect(project.reload.completed?).to be true
    expect(page).to have_content "Congratulations, this project is complete!"
    expect(page).to have_content "Completed"
    expect(page).to_not have_button "Complete"
  end

  scenario "完了済のプロジェクトは非表示にする" do
    user = FactoryBot.create(:user)
    project = FactoryBot.create(:project, owner: user)

    sign_in user

    visit project_path(project)

    expect(page).to_not have_content "Completed"

    click_button "Complete"

    visit root_path
    save_and_open_page
    expect(page).to_not have_content project.name

  end
end
