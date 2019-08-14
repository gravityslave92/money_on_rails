Rails.application.config.filter_parameters +=
    %i[ password password_confirmation credit_card_number
     expiration_month expiration_year cvc]
