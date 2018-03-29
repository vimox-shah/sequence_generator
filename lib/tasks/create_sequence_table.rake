task :create_sequence_table => :environment do
  # ActiveRecord::Base.establish_connection adapter: 'pg', database: ENV['POSTGRES_DB']
  db_conf = YAML.safe_load(File.expand_path(File.open('config/database.yml')))
  p db_conf, 'db_conf'
  ActiveRecord::Base.establish_connection(db_conf[::Rails.env])
  ActiveRecord::Schema.define do
    table_list = ActiveRecord::Base.connection.tables
    unless table_list.include? 'sequences'
      create_table :sequences do |table|
        table.column :company_id, :string
        table.column :branch_id, :string
        table.column :sequence_prefix, :string
        table.column :sequential_id, :integer
        table.column :start_at, :integer
        table.column :valid_from, :date
        table.column :valid_till, :date
        table.column :reset_from_next_year, :boolean
        table.column :purpose, :string
        table.column :financial_year_start, :string
        table.column :financial_year_end, :string
        table.column :created_at, :datetime
        table.column :updated_at, :datetime

      end
      add_index :sequences, %i[id]
      add_index :sequences, %i[company_id]
      add_index :sequences, %i[branch_id]
      add_index :sequences, %i[sequential_id]
      add_index :sequences, %i[sequence_prefix]
    end
  end
end