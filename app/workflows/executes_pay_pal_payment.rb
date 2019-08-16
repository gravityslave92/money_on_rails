class ExecutesPayPalPayment
  attr_accessor :payment_id, :token, :payer_id,
                :payment, :success, :continue

  def initialize(payment_id:, token:, payer_id:)
    @payment_id = payment_id
    @token = token
    @payer_id = payer_id
    @success = false
    @continue = true
  end

  def payment
    @payment ||= Payment.find_by(payment_method: "paypal", response_id: payment_id)
  end

  def pay_pal_payment
    @pay_pal_payment ||= PayPalPayment.find(payment_id)
  end

  def run
    Payment.transaction do
      pre_purchase
      purchase
      post_purchase
    end
  end

  def pre_purchase
    self.continue = pay_pal_payment.valid?
  end

  def purchase
    return unless continue

    self.continue = pay_pal_payment.execute(payer_id: payer_id)
  end

  def post_purchase
    if continue
      purchase_payment_tickets
      return
    end

    payment.tickets.each(&:waiting!)
    payment.failed!
  end

  private

  def purchase_payment_tickets
    payment.tickets.each(&:purchased!)
    payment.succeeded!
    self.success = true
  end


end
