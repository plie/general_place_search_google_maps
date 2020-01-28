class MapSearchService
  include HTTParty
  require 'nokogiri'

  base_uri "https://maps.googleapis.com/maps/api/place/nearbysearch"
  # "Nearby Search" can search by type and is well suited to search within a specified area for keywords
  # "Find Place" does not allow searching based on type
  # "Text Search" allows searching by type and address and is based on a single point of location

  def initialize(params)
    @output = params['response_output']&.downcase
    @language = select_language_code(params['language']&.downcase)
    @location = "#{params['latitude']},#{params['longitude']}"
    @type = (params['type'])&.downcase
    @radius = select_radius
    @keywords = (params['customer_name'])&.split(' ')&.join('+')&.downcase
    @number_of_locations = params['number_of_locations'].to_i
  end

  def lookup
    @response = search_google_api

    if @output == 'json'
      parse_json
    else
      parse_xml
    end
  end

  private

  def search_google_api
    self.class.get(
      "/#{@output}?language=#{@language}&location=#{@location}&radius=#{@radius}#{optional_search_by_type}&keyword=#{@keywords}&key=#{ENV['GOOGLE_MAPS_KEY']}",
      format: :plain
    )
  end

  def parse_xml
    search_results = Nokogiri.XML(@response)
    locations = search_results.css("result").map { |node| node.children.text }
    locations = locations.map do |item|
       item.split("\n\s\s").first(3).drop(1)
    end
    locations = locations.map do |location|
      [{'name' => location[0], 'vicinity' => location[1]}]
    end
    locations.first(@number_of_locations)
  end

  def parse_json
    search_results = JSON.parse(@response, symbolize_names: :true)
    locations = search_results[:results].map do |location|
      [{'name' => location[:name], 'rating' => location[:rating], 'vicinity' => location[:vicinity]}]
    end
    locations.first(@number_of_locations)
  end

  def select_language_code(language)
    case language
    when 'french' then 'fr'
    when 'english' then 'en'
    when 'spanish' then 'es'
    end
  end

  def select_radius
    @type ? 15000 : 5000
  end

  def optional_search_by_type
    @type == 'all' ? '' : "&type=#{@type}"
  end
end


