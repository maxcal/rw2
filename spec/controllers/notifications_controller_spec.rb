require "spec_helper"

describe NotificationsController do

  describe "GET 'index'" do

    let(:note) { create(:notification) }
    let(:user) { user = create(:user) }

    before :each do
      sign_in user
    end

    it "should handle an empty set gracefully" do
      get :index, page: 4
      expect(response).to be_success
    end

    it "redirects if user is not logged in" do
      sign_out user
      expect {
        get :index
      }.to raise_error
    end

    it "assigns current user as @user" do
      get :index
      expect(assigns(:user).id).to eq user.id
    end

    it "does not allow user notifications which are not adressed to her" do
      private = create(:notification, user_id: 9999)
      get :index
      expect(assigns(:notifications)).to_not include private
    end

    it "allows user to see notifications addressed to her" do
      private = create(:notification, user_id: user.id)
      get :index
      expect(assigns(:notifications)).to include private
    end

    it "sets notifications as read after render" do
      create(:notification, user_id: user.id)
      get :index
      expect(assigns(:notifications).first.read).to be_true
    end

    it "sorts notifications in descending order" do
      create(:notification, user: user)
      note2 = create(:notification, user: user )
      note2.update_attribute(:created_at, 1.year.ago)
      get :index
      expect(assigns(:notifications).first.created_at).to be > assigns(:notifications).last.created_at
    end

    it "uses page parameter to paginate notifications" do
      ActiveRecord::Relation
                    .any_instance
                    .should_receive(:paginate)
                    .with(page: "4")
                    .and_return(Notification)
      #Notification
      get :index, page: 4
    end

    it "flashes when user has unread notifications" do
      create(:notification, user: user)
      get :index
      expect(flash[:notice]).to include "You have 1 unread notification."
    end
  end

  describe "PATCH 'mark_all_as_read'" do

    let(:user) { user = create(:user) }
    let(:note) { create(:notification, user: user) }

    before(:each) { sign_in user }
    subject { response }

    context "when user has no unread notifications" do

      before(:each) do
        patch :mark_all_as_read
      end

      it { should redirect_to /#{notifications_url}/ }

      it "should flash error" do
        expect(flash[:error]).to match /no unread notifications found/i
      end

    end

    context "when user has notifications" do

      before(:each) do
         note
         patch :mark_all_as_read
      end

      it { should redirect_to /#{notifications_url}/ }

      it "should redirect to notifications" do
        expect(flash[:success]).to match /all notifications have been marked as read/i
      end

      it "set all notifications as read" do
        expect(note.reload.read).to be_true
      end

    end

    it "should not change notifications that do not belong to current user" do
      private = create(:notification, user_id: 999)
      patch :mark_all_as_read
      expect(private.reload.read).to be_false
    end

  end
end