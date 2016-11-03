require 'rails_helper'

describe StationSerializer do
  include Rails.application.routes.url_helpers

  it "has the correct id" do
    expect(subject[:id]).to eq resource[:id]
  end
  it "has the correct latitude" do
    expect(subject.latitude).to eq resource[:latitude]
  end
  it "has the correct latitude" do
    expect(subject.longitude).to eq resource[:longitude]
  end
  it "has the correct name" do
    expect(subject.name).to eq resource[:name]
  end
  it "has the correct slug" do
    expect(subject.slug).to eq resource[:slug]
  end
  it "has the correct path" do
    expect(subject.path).to eq station_path(resource)
  end
  it "has the correct status" do
    expect(subject.status).to eq resource.status
  end
end
