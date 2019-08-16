class StripeCharge

  attr_accessor :token, :payment, :response, :error

  def initialize(token, payment)
    @token = token
    @payment = payment
  end

  def charge
    return if response.present?

    self.response = Stripe::Charge.create(
      { amount: payment.price.cents, currency: 'usd',
        source: token.id, description: '',
        metadata: { reference: payment.reference } },
      idempotency_key: payment.reference
    )
  rescue Stripe::StripeError => e
    self.response = nil
    self.error = e
  end

  def success?
    response || !error
  end

  def payment_attributes
    success? ? success_attributes : failure_attributes
  end

  def success_attributes
    {
      status: response.status,
      response_id: response.id,
      full_response: response.to_json
    }
  end

  def failure_attributes
    {
      status: :failed,
      full_response: error.to_json
    }
  end

  class << self
    def charge(token:, payment:)
      stripe_charge = new(token, payment)
      stripe_charge.charge
      stripe_charge
    end
  end
end