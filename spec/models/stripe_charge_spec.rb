require 'rails_helper'

describe StripeCharge, :vcr do
  let(:token) do
    StripeToken.new(credit_card_number: '4242424242424242', expiration_month: '12',
                    expiration_year: Time.zone.now.year + 1, cvc: '123')
  end
  let(:payment) do
    build_stubbed(:payment, price: Money.new(3000),
                  reference: Payment.generate_reference)
  end

  it 'calls stripe to get a charge' do
    charge = StripeCharge.charge(token: token, payment: payment)
    expect(charge.id).to start_with('ch')
    expect(charge.amount).to eq(3000)
  end
end
