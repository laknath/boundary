module Boundary
  module Model
    # Adds a scope helper for the specified scope (ie: company)
    #
    # Options:
    # * <tt>:foreign_id</tt> - Foreign ID column name (default: :company_id)
    #
    # bound_by :account, :foreign_id => :employee_id
    #
    # Subscription.bound_by_account(account_id) { query }
    def bound_by(scope, *args)
      options = args.extract_options!

      options[:foreign_id]  ||= :company_id

      self.class_eval <<-"end_eval", __FILE__, __LINE__
          def self.bound_by_#{scope}(foreign_id, *args)
            self.where(:#{options[:foreign_id]} => foreign_id).scoping do
              yield if block_given?
            end
          end
      end_eval
    end
  end
end
