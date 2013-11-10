# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  sequence(:hw_id) { |n| "hw_id_#{n}" }

  factory :station do
    name "Test Station"
    hw_id
    latitude 51.478885
    longitude -0.010635
    balance 1.5
    down false
    user nil
  end
end
