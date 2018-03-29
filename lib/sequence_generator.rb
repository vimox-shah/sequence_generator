require "sequence_generator/version"
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/class/attribute_accessors'

module SequenceGenerator
  module ActsAsSequenced
    class Sequence < ActiveRecord::Base
      include ActiveModel::Model

      DEFAULT_OPTIONS = {
          column: :sequential_id,
          purpose: 'Sequence',
          sequential_id: 1,
          start_at: 1
      }.freeze

      ColumnWithSamePurposeExists = Class.new(StandardError)

      validates_presence_of :sequential_id, :purpose
      before_validations :set_sequential_ids

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def act_as_sequenced(options= {})
          unless defined?(sequenced_options)
            include SequenceGenerator::ActsAsSequenced::InstanceMethods

            mattr_accessor :sequenced_options, instance_accessor: false
            self.sequenced_options = []
          end

          options = DEFAULT_OPTIONS.merge(options)
          column_name = options[:column]
          purpose = options[:purpose]

          if sequenced_options.any? { |options| options[:column] == column_name && options[:purpose] == purpose }
            raise(ColumnWithSamePurposeExists, <<-MSG.squish)
              Tried to set #{column_name} as sequenced but there was already a
              definition here. Did you accidentally call acts_as_sequenced
              multiple times on the same column with same purpose?
            MSG
          else
            sequenced_options << options
          end
        end
      end

      module InstanceMethods
        def set_sequential_ids
          self.class.base_class.sequenced_options.each do |options|
            SequenceGenerator::Generator.new(self, options).generate_sequence_number
          end
        end
      end

    end
  end
end
