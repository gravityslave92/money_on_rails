require 'rails_helper'

describe PreparesCartForPayPal, :vcr, :aggregate_failures do
  describe 'successful credit card purchase' do
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
      PreparesCartForPayPal.new(user: user, purchase_amount_cents: 3000,
                                expected_ticket_ids: "#{ticket_1.id} #{ticket_2.id}",
                                payment_reference: 'reference') 
    end

    before(:example) do
      [ticket_1, ticket_2].each { |t| t.place_in_cart_for(user) }
      workflow.run
    end

    it 'updates the ticket status' do
      [ticket_1, ticket_2, ticket_3].each(&:reload)
      expect([ticket_1, ticket_2]).to  all(be_pending)
      expect(ticket_3).not_to be_pending
      expect(workflow.success).to be_truthy
      expect(workflow.payment).to have_attributes(
        user_id: user.id, price_cents: 3000,
        reference: a_truthy_value, payment_method: 'paypal'
      )
      expect(workflow.payment.payment_line_items.size).to eq(2)
      expect(workflow.redirect_on_success_url).to start_with(
          'https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout')
      expect(workflow.payment.response_id).to eq(
          workflow.pay_pal_payment.pay_pal_payment.id)
    end
  end
end
