require 'rails_helper'

RSpec.describe TasksController, type: :controller do
	before do
		@user = FactoryBot.create(:user)
		@project = FactoryBot.create(:project, owner: @user)
		@task = @project.tasks.create(name: "Test task")
	end

	describe "#show" do
		it "JSON形式でレスポンスを返すこと" do
			sign_in @user
      get :show, format: :json,
			params: { project_id: @project.id, id: @task.id }
			expect(response.content_type).to eq "application/json"
		end
	end

	describe '#create' do
		it 'JSONでレスポンスを返すこと' do
			new_task = { name: "New test task" }
			sign_in @user
			post :create, format: :json, params: { project_id: @project.id, task: new_task }
			expect(response.content_type).to eq "application/json"
		end
		it '新しいプロジェクトを追加すること' do
			new_task = { name: "New test task" }
			sign_in @user
			expect {
				post :create, format: :json, params: { project_id: @project.id, task: new_task }
			}.to change(@project.tasks, :count).by(1)
		end
	end

end
