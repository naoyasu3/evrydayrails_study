require 'rails_helper'

RSpec.describe "ProjectsApis", type: :request do
  describe "GET /projects_apis" do

    describe "Projects API" do
      it "1件のプロジェクトを読み出すこと" do
        user = FactoryBot.create(:user)
        FactoryBot.create(:project, name: "Sample Project")
        FactoryBot.create(:project, name: "Second Sample Project", owner: user)

        get api_projects_path, params: {
          user_email: user.email,
          user_token: user.authentication_token
        }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json.length).to eq 1
        project_id = json[0]["id"]

        get api_project_path(project_id), params: {
          user_email: user.email,
          user_token: user.authentication_token
        }

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq "Second Sample Project"
      end

      it 'プロジェクトを作成できること' do
        user = FactoryBot.create(:user)
        project_attributes = FactoryBot.attributes_for(:project)

        expect {
          post api_projects_path, params: {
            user_email: user.email,
            user_token: user.authentication_token,
            project: project_attributes
          }
        }.to change(user.projects, :count).by(1)

        expect(response).to have_http_status(:success)
      end

      it '正常なレスポンスを返すこと' do
        get root_path
        expect(response).to be_success
        expect(response).to have_http_status "200"
      end

      context "認証済なユーザとして" do
        before do
          @user = FactoryBot.create(:user)
        end

        context "有効な属性の場合" do
          it "プロジェクトを追加できること" do
            project_params = FactoryBot.attributes_for(:project)
            sign_in @user
            expect {
              post projects_path, params: { project: project_params }
            }.to change(@user.projects, :count).by(1)
          end
        end

        context "無効な属性の場合" do
          it "プロジェクトを追加できないこと" do
            project_params = FactoryBot.attributes_for(:project, :invalid)
            sign_in @user
            expect {
              post projects_path, params: { project: project_params }
            }.to_not change(@user.projects, :count)
          end
        end
      end
    end
  end
end
