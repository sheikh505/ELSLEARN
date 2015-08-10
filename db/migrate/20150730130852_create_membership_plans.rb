class CreateMembershipPlans < ActiveRecord::Migration
  def change
    create_table :membership_plans do |t|
      t.integer :price
      t.string :paper
      t.integer :max_questions_allowed
      t.integer :result_type
      t.integer :validity
      t.integer :other_course_amount

      t.timestamps
    end
  end
end
