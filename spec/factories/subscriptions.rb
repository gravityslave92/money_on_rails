FactoryBot.define do
  factory :subscription do
    user { nil }
    plan { nil }
    start_date { "2019-08-16" }
    end_date { "2019-08-16" }
    status { 1 }
    payment_method { "MyString" }
    remote_id { "MyString" }
  end
end
