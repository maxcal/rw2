require 'spec_helper'

describe "devise/passwords/new" do

  before do
    view.stub(:resource).and_return(User.new)
    view.stub(:resource_name).and_return(:user)
    view.stub(:resource_class).and_return(Devise.mappings[:user].to)
    view.stub(:devise_mapping).and_return(Devise.mappings[:user])
  end

  subject { render; rendered }

  it { should have_field "Email" }
  it { should have_button "Send" }
end
