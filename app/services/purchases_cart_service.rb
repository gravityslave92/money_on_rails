class PurchasesCartService

  attr_accessor :user, :stripe_token, :purchase_amount,
                :success, :payment

  def initialize(user, stripe_token, purchase_amount_cents)
    @user = user
    @stripe_token = stripe_token
    @purchase_amount = Money.new(purchase_amount_cents)
    @success = false
  end

  def call
    make_payment_transaction
    return false unless success

    payment
  end

  class << self
    def call(user:, stripe_token:, purchase_amount_cents:)
      new(user, stripe_token, purchase_amount_cents)
      .call
    end
  end

  private

  def make_payment_transaction
    Payment.transaction do
      purchase_tickets
      create_payment
      charge
    end
  end

  def tickets
    @tickets ||= user.tickets_in_cart
  end

  def purchase_tickets
    tickets.each(&:purchased!)
  end

  def create_payment
    self.payment = Payment.create!(payment_attributes)
    payment.create_line_items(tickets)
  end

  def payment_attributes
    {
      user_id: user.id,
      price_cents: purchase_amount.cents,
      status: "created",
      reference: Payment.generate_reference,
      payment_method: "stripe"
    }
  end

  def charge
    charge = StripeCharge.charge(token: stripe_token, payment: payment)
    payment.update!(
      status: charge.status,
      response_id: charge.id,
      full_response: charge.to_json
    )

    self.success = payment.succeeded?
  end
end