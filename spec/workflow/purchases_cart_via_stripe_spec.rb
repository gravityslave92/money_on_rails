require 'rails_helper'

describe PurchasesCartViaStripe, :vcr, :aggregate_failures do
  describe 'successful credit card purchase' do
    let(:reference) { Payment.generate_reference }
    let(:ticket_1) do
      instance_spy(Ticket, status: 'waiting', price: Money.new(1500), id: 1)
    end
    let(:ticket_2) do
      instance_spy(Ticket, status: 'waiting', price: Money.new(1500), id: 2)
    end
    let(:ticket_3) { instance_spy(Ticket, status: 'unsold', id: 3) }
    let(:user) do
      instance_double(User, id: 5, tickets_in_cart: [ticket_1, ticket_2])
    end
    let(:token) do
      StripeToken.new(
        credit_card_number: '4242424242424242', expiration_month: '12',
        expiration_year: Time.zone.now.year + 1, cvc: '123'
      )
    end
    let(:workflow) do
      PurchasesCartViaStripe.new(
        user: user, purchase_amount_cents: 3000,
        stripe_token: token
      )
    end
    let(:attributes) do
      { user_id: user.id, price_cents: 3000,
        reference: a_truthy_value, payment_method: 'stripe',
        status: 'created' }
    end
    let(:payment) do
      instance_double(Payment, succeeded?: true,
                               price: Money.new(3000), reference: reference)
    end

    before(:example) do
      allow(Payment).to receive(:create!).with(attributes).and_return(payment)
      allow(payment).to receive(:update!).with(
        status: 'succeeded', response_id: a_string_starting_with('ch_'),
        full_response: a_truthy_value
      )
      expect(payment).to receive(:create_line_items).with([ticket_1, ticket_2])
      workflow.run
    end

    it 'updates the ticket status' do
      expect(ticket_1).to have_received(:purchased!)
      expect(ticket_2).to have_received(:purchased!)
      expect(ticket_3).not_to have_received(:purchased!)
      expect(workflow.payment_attributes).to match(attributes)
      expect(workflow.success).to be_truthy
    end
  end
end
