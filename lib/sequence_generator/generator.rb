module SequenceGenerator
  class Generator
    attr_reader :record, :scope, :column, :start_at, :purpose, :sequential_id,
                :valid_from, :valid_till, :seller_id, :company_id, :financial_year_start,
                :financial_year_end

    def initialize(record, options = {})
      @record = record
      @scope = options[:scope]
      @column = options[:column].to_sym
      @start_at = options[:start_at]
      @purpose = options[:purpose]
      @valid_from = options[:valid_from]
      @valid_till = options[:valid_till]
      @seller_id = options[:seller_id]
      @sequential_id = options[:sequential_id]
      @company_id = options[:company_id]
      @financial_year_start = options[:financial_year_start]
      @financial_year_end = options[:financial_year_end]
    end

    def create_sequence
      Sequence.create!(sequential_id: sequential_id, branch_id: seller_id,
                       purpose: purpose, company_id: company_id,
                       valid_till: valid_till,
                       valid_from: valid_from,
                       financial_year_start: financial_year_start,
                       financial_year_end: financial_year_end)
    end

    def generate_sequence_number
      sequence = Sequence.where(branch_id: seller_id, purpose: purpose).first
      sequence_number = "%05d" % (sequence.sequential_id + 1).to_s
      sequential_id = "#{sequence.sequence_prefix}#{"/"}#{sequence_number}"
      if sequence.present?
        if valid_from.present? and valid_till.present?
          if Time.now <= sequence.valid_till && Time.now >= sequence.valid_from
            sequence.update(sequential_id: sequence.sequential_id + 1)
            return sequential_id
          end
        else
          sequence.update(sequential_id: sequence.sequential_id + 1)
          return sequential_id
        end
      else
        Sequence.create(branch_id: seller_id, purpose: 'Sequence')
        set
      end
    end

    def set
      return if id_set? || skip?
      lock_table
      record.send(:"#{column}=", next_id)
    end

    def id_set?
      !record.send(column).nil?
    end

    def skip?
      skip && skip.call(record)
    end

    def next_id
      next_id_in_sequence.tap do |id|
        id += 1 until unique?(id)
      end
    end

    def next_id_in_sequence
      start_at = self.start_at.respond_to?(:call) ? self.start_at.call(record) : self.start_at
      return start_at unless last_record = find_last_record
      max(last_record.send(column) + 1, start_at)
    end

    def unique?(id)
      build_scope(*scope) do
        rel = base_relation
        rel = rel.where("NOT id = ?", record.id) if record.persisted?
        rel.where(column => id)
      end.count == 0
    end

    private

    def lock_table
      if postgresql?
        record.class.connection.execute("LOCK TABLE #{record.class.table_name} IN EXCLUSIVE MODE")
      end
    end

    def postgresql?
      defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) &&
          record.class.connection.instance_of?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
    end

    def base_relation
      record.class.base_class.unscoped
    end

    def find_last_record
      build_scope(*scope) do
        base_relation.
            where("#{column.to_s} IS NOT NULL").
            order("#{column.to_s} DESC")
      end.first
    end

    def build_scope(*columns)
      rel = yield
      columns.each { |c| rel = rel.where(c => record.send(c.to_sym)) }
      rel
    end

    def max(*values)
      values.to_a.max
    end

  end
end
