require "sequence_generator/version"
require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/class/attribute_accessors'
require "sequence_generator/act_as_sequenced"
require 'railtie' if defined?(Rails)

module SequenceGenerator
  class Sequence < ActiveRecord::Base
    include ActiveModel::Model
    include ActsAsSequenced

    validates_presence_of :sequential_id, :purpose
    before_validation :set_sequential_ids
    ActiveRecord::Base.send(:include, ActsAsSequenced)
  end
end
