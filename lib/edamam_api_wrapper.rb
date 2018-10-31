require 'httparty'

class EdamamApiWrapper
  BASE_URL = "https://api.edamam.com/search"
  ID = ENV["EDAMAM_ID"]
  KEY = ENV["EDAMAM_KEY"]

  def self.list_recipes(term)
    url = BASE_URL + "?q=#{term}" + "&app_id=#{ID}" + "&app_key=#{KEY}" + "&from=0" + "&to=30"

    data = HTTParty.get(url)

    recipe_list = []

    if data["hits"]
      data["hits"].each do |recipe_data|
        recipe_list << create_recipe(recipe_data)
      end
      return recipe_list
    else
      return []
    end
  end

  def self.recipe_details(id)
    url = BASE_URL + "?&app_id=#{ID}" + "&app_key=#{KEY}" + "&r=http://www.edamam.com/ontologies/edamam.owl#recipe_" + "#{id}"

    encoded_url = URI.encode(url)
    data = HTTParty.get(encoded_url)

    return recipe_data(data)
  end


  private

  def self.create_recipe(api_params)
    return Recipe.new(
      api_params["recipe"]["label"],
      api_params["recipe"]["image"],
      api_params["recipe"]["uri"]
    )
  end

  def self.recipe_data(api_params)
    return Recipe.new(
      api_params[0]["label"],
      api_params[0]["image"],
      api_params[0]["uri"],
      original_url: api_params[0]["url"],
      ingredients: api_params[0]["ingredientLines"],
      diet_labels: api_params[0]["dietLabels"],
      health_labels: api_params[0]["healthLabels"],
      source: api_params[0]["source"]
    )
  end
end
