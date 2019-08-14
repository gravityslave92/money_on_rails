require 'rails_helper'

RSpec.describe Performance, type: :model do
  describe 'finders' do
    let(:event) { create(:event) }
    let(:performance) { create(:performance, event: event) }
    let(:unsold_ticket) do
      create(:ticket, status: 'unsold', performance: performance)
    end
    let(:sold_ticket) do
      create(:ticket, status: 'sold', performance: performance)
    end

    it 'can find unsold tickets' do
      expect(performance.unsold_tickets(1)).to eq([unsold_ticket])
    end
  end
end
