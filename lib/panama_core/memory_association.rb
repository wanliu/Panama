# encoding: utf-8
module PanamaCore
  # 使 ActiveRecord::Base 支持内存 Association, 未使用此插件的情况下 ActiveRecord 的关联关系,
  # 必须在 Record 持久存储的情况下,才能建立与保存 association, 所以这工具将赋予我们一种内存化的关联
  # 状态,并且能使其正确的保存与 callback
  module MemoryAssociation
    extend ActiveSupport::Concern

    included do |klass|

      cattr_accessor :memory_associations
      @@memory_associations = []

      after_save :lazy_memory_association_save

      after_initialize do |record|
        memory_associations.each do |_assoc|

          record.association(_assoc).class_eval do
            include ForkMethod
          end
        end
      end
    end

    module ForkMethod

      def concat(*args)
        if owner.persisted?
          super
        else
          records = args.flatten
          target.concat records
          records.each do |record|
            callback(:after_add, record)
          end
        end
      end
    end

    module ClassMethods
      # 类方法, memories [association, ....]
      # assocation 一个关联的 symbol 名称
      def memories(*args)
        memory_associations.concat args
      end
    end


    def lazy_memory_association_save
      memory_associations.each do |association|
        _association = send(association)
        replace_relations(_association)
      end
    end
  end
end