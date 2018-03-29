class SequenceGenerator::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/create_sequence_table.rake'
  end
end