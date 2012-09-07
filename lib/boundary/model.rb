module Boundary
  module Model
    # Adds a scope helper for the specified scope (ie: company)
    #
    # Options:
    # * <tt>:foreign_id</tt> - Foreign ID column name (default: :company_id)
    #
    # add_scope :account, :foreign_id => :employee_id
    #
    # Subscription.scoped_by_account(account_id) { ... }
    def add_scope(scope, *args)
      options = args.extract_options!

      options[:foreign_id]    ||= scope.to_s.foreign_key 
      options[:scope_trail]   ||= {}
      options[:source_table]  ||= source_table(options[:scope_trail])

      # Ex: Transaction.joins(:subscription => {:subscription_plan => :company}).where(:subscription_plans => {:company_id => 6})
      self.class_eval <<-"end_eval", __FILE__, __LINE__
          def self.scoped_by_#{scope}(foreign_id, *args)
            self.joins(#{options[:scope_trail]}).where(:#{options[:source_table]} => {:#{options[:foreign_id]} => foreign_id}).scoping do
              yield if block_given?
            end
          end
      end_eval
    end

    private
    # Extracted from SamLown.com - http://www.samlown.com/en/recursive_lambdas_and_how_to_completely_flatten_a_hash_in_ruby
    def flatten_hash(hash) #:nodoc:
      flatten = lambda {|v|
        if v.is_a?(Hash)
          v.to_a.map{|v| flatten.call(v)}.flatten
        elsif v.is_a?(Array)
          v.flatten.map{|v| flatten.call(v)}
        else
          v.to_s
        end
      }
      flatten.call(hash)
    end

    def source_table(scope_trail)
      (source_table = flatten_hash(scope_trail).last || self.name) && source_table.tableize
    end
  end
end
