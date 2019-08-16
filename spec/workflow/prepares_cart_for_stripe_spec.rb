require 'rails_helper'

describe PreparesCartForStripe, :vcr, :aggregate_failures do
  let(:performance) { create(:performance, event: create(:event)) }
  let(:reference) { Payment.generate_reference }
  let(:ticket_1) do
    create(:ticket, status: 'waiting', price: Money.new(1500),
           performance: performance, payment_reference: 'reference')
  end
  let(:ticket_2) do
    create(:ticket, status: 'waiting', price: Money.new(1500),
           performance: performance, payment_reference: 'reference')
  end
  let(:ticket_3) do
    create(:ticket, status: 'unsold', performance: performance,
           payment_reference: 'reference')
  end
  let(:user) { create(:user) }
  let(:workflow) do
    PreparesCartForStripe.new(user: user, purchase_amount_cents: 3000,
                              expected_ticket_ids: "#{ticket_1.id} #{ticket_2.id}",
                              payment_reference: 'reference', stripe_token: token) 
  end
  
  let(:attributes) do
    { user_id: user.id, price_cents: 3000,
     reference: a_truthy_value, status: 'created' } 
  end

  before(:example) do
    [ticket_1, ticket_2].each { |t| t.place_in_cart_for(user) }
  end

  describe 'successful credit card purchase' do
    let(:token) do
      StripeToken.new(credit_card_number: '4242424242424242', expiration_month: '12',
                      expiration_year: Time.zone.now.year + 1, cvc: '123') 
    end

    it 'updates the ticket status' do
      workflow.run
      expect([Ticket.find(ticket_1.id), Ticket.find(ticket_2.id) ]).to all(be_purchased)
      expect(Ticket.find(ticket_3.id)).not_to be_purchased
      expect(workflow.success).to be_truthy
      expect(workflow.payment_attributes).to match(attributes)
      expect(workflow.success).to be_truthy
      expect(workflow.payment.payment_line_items.size).to eq(2)
    end
  end

  describe 'pre-flight fails' do
    let(:token) { instance_spy(StripeToken) }

    describe 'expected price' do
      let(:workflow) do
        PreparesCartForStripe.new(user: user, purchase_amount_cents: 2500,
                                  stripe_token: token,
                                  expected_ticket_ids: "#{ticket_1.id} #{ticket_2.id}")
      end

      it 'does not payment if the expected price is incorrect' do
        expect { workflow.run }.to raise_error(ChargeSetupValidityException)
        expect(workflow).not_to be_pre_purchase_valid
        expect([Ticket.find(ticket_1.id), Ticket.find(ticket_2.id)]).to all(be_waiting)
        expect(Ticket.find(ticket_3.id)).to be_unsold
        expect(workflow.success).to be_falsy
        expect(workflow.payment).to be_nil
      end
    end

    describe 'expected tickets' do
      let(:workflow) do
        PreparesCartForStripe.new(user: user, purchase_amount_cents: 3000,
                                  stripe_token: token,
                                  expected_ticket_ids: "#{ticket_1.id} #{ticket_3.id}")
      end

      it 'does not payment if the expected tickets are incorrect' do
        expect { workflow.run }.to raise_error(ChargeSetupValidityException)
        expect(workflow).not_to be_pre_purchase_valid
        expect([Ticket.find(ticket_1.id), Ticket.find(ticket_2.id)]).to all(be_waiting)
        expect(Ticket.find(ticket_3.id)).to be_unsold
        expect(workflow.success).to be_falsy
        expect(workflow.payment).to be_nil
      end
    end
  end
end
