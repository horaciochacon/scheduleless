class LocationsController < AuthenticatedController
  def index
    @locations = current_company.locations
  end
end
