class Initial < ActiveRecord::Migration
  def change
    create_table :fallibles do |t|
      t.string 'kind'
      t.string 'env'
      t.string 'name'
      t.timestamps
    end

    create_table :failures do |t|
      t.references :fallible
      t.datetime 'started_at'
      t.datetime 'ended_at'
      t.timestamps
    end

    create_table :shard_bodies do |t|
      t.references :failure
      t.string 'shard'
      t.text 'body'
      t.timestamps
    end

    create_table :human_replies do |t|
      t.references :fallible
      t.string 'from'
      t.datetime 'sent_at'
      t.text 'body'
      t.timestamps
    end

    create_table :settings do |t|
      t.string 'key'
      t.text 'value'
    end
  end
end
