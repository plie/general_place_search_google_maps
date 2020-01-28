class PlacesController < ApplicationController

  def index
  end

  def search
    @results = text_search(params)
    unless @results
      flash[:alert] = "There are no locations found. Please try again."
      return render action: :index
    end

    @results
  end

  private

  def text_search(search_criteria)
    map = MapSearchService.new(search_criteria)
    map.lookup
  end
end
