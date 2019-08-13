# frozen_string_literal: true

class ShoppingCartsController < ApplicationController
  def show
    @cart = ShoppingCart.new(current_user)
  end

  def update
    performance = Performance.find(params[:performance_id])
    workflow = AddsToCartService.call(
      user: current_user, performance: performance,
      count: params[:ticket_count]
    )

    if workflow.success
      redirect_to shopping_cart_path
    else
      redirect_to performance.event
    end
  end
end