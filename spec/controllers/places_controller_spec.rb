require 'rails_helper'

RSpec.describe PlacesController, type: :controller do

  describe '#index' do
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe '#search' do
    it "renders the search results template" do
      get :search
      expect(response).to render_template("search")
    end
  end

  describe '#search' do
    it "returns an array" do
      get :search { customer_name: }
      # binding.pry
      expect(response.body).to be_an_instance_of(Array)
    end
  end
end
