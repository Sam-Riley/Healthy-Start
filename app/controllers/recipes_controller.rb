class RecipesController < ApplicationController
  ENV['edamam_app_id']
  ENV['edamam_key']
  # The ENV variable are storing the app_id and also the key so I can use them anytime they are needed

  def index
    @recipe = Recipe.all
    render json: @recipe
  end

  # The search
  def search
    cache params[:food] do
      @response = HTTParty.get("https://api.edamam.com/search?q=#{params[:food]}", headers: { 'app_id' => ENV['edamam_app_id'], 'app_key' => ENV['edamam_key'] })
      @recipies = []
      @response['hits'].each do |nut|
        recipe = Recipe.find_or_create_by(
          recipe_name: nut['recipe']['label'],
          instruction: nut['recipe']['url'],
          food_image: nut['recipe']['image']
        )
        nut['recipe']['ingredients'].each do |fd|
          puts fd.inspect
          food = Food.find_or_initialize_by(
            name: fd['food']
          )
          recipe.foods << food unless recipe.foods.include?(food)
        end
        @recipies << recipe
      end

    end
    render json: @recipies
  end

  def show
    @recipe = Recipe.find(params[:id])
    render json: @recipe
  end

  def show_foods
    @food = Food.find(params[:id])
    render json: @food
  end

  # private
  #
  # def custom_params(pots)
  #   {
  #     name: pots.label
  #   }
  # end
end
