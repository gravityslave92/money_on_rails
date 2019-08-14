module HasReference
  extend ActiveSupport::Concern

  module ClassMethods

    def generate_reference
      while true do
        result = SecureRandom.hex(10)
        return result unless exists?(reference: result)
      end
    end
  end
end