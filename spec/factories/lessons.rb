FactoryBot.define do
  factory :lesson do
    sequence(:title) { |n| "Lesson #{n}: Trading Basics" }
    content { Faker::Lorem.paragraphs(number: 3).join('\n\n') }
    prerequisites { nil }
    xp_reward { 50 }
    unlock_level { 1 }
    sequence(:position)
    published { true }

    trait :advanced do
      unlock_level { 5 }
      xp_reward { 100 }
    end

    trait :unpublished do
      published { false }
    end

    trait :intro_lesson do
      title { 'Introduction to Stock Markets' }
      content { '<h2>Welcome to trading!</h2><p>This is your first lesson.</p>' }
      position { 1 }
      unlock_level { 1 }
    end
  end
end
