class CreateBonds < ActiveRecord::Migration
  def change
    create_table :bonds do |t|
      t.string :actor_id
      t.string :actor_type
      t.string :act_object_id
      t.string :act_object_type
      t.string :act_target_id
      t.string :act_target_type
      t.string :verb
      t.string :name

      t.integer :score,     :default => 0
      t.integer :increases, :default => 0
      t.integer :decreases, :default => 0

      t.text :options

      t.timestamps
    end

    add_index "bonds", ["verb", "actor_id", "actor_type", "act_object_id", "act_object_type", "act_target_id", "act_target_type"  ],                             :name => "index_bonds_on_all_fields"
    add_index "bonds", ["verb"],                             :name => "index_bonds_on_verb"
    add_index "bonds", ["actor_id", "actor_type"],           :name => "index_bonds_on_actor_id"
    add_index "bonds", ["act_object_id", "act_object_type"], :name => "index_bonds_on_act_object_id"
    add_index "bonds", ["act_target_id", "act_target_type"], :name => "index_bonds_on_act_target_id"

  end
end
