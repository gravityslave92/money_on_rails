class AddsToCart
  attr_accessor :user, :performance, :count, :success

  def initialize(user:, performance:, count:)
    @user = user
    @performance = performance
    @count = count.to_i
    @success = false
  end

  def run
    Ticket.transaction do
      tickets = performance.unsold_tickets(count)
      return if tickets.size != count

      place_tickets_in_cart(tickets)
      success
    end
  end

  private

  def place_tickets_in_cart(tickets)
    tickets.each { |ticket| ticket.place_in_cart_for(user) }
    self.success = tickets.all?(&:valid?)
  end
end
