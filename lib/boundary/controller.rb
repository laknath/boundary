module Boundary
  module Controller
    # Adds a scope helper that call the model with a given parameter (ie: subdomain)
    #
    # Options:
    # * <tt>:by</tt> - Target scope model name (default: :company)
    # * <tt>:scope_function</tt> - Name of a function that returns the target scope object. This object should contain an ID column that matches with the foreign_id column of the scoped object (default: :current_company)
    #
    # bound_to :subscription, :by => :account, :scope_function => :current_employee
    #
    # In your actions,
    #
    # def show
    #   @subscription = bound_by_account { Subscription.find(params) }
    #   ...
    # end
    #
    # For multiple scopes,
    #
    # bound_to :subscription, :by => :account, :scope_function => :current_employee
    # bound_to :transaction, :by => :account, :scope_function => :current_employee
    #
    # def show
    #   @subscription = subscription_bound_by_account { Subscription.find(params) }
    #   @transaction  = transaction_bound_by_account { Transaction.find(params) }
    # end
    def bound_to(model, *args, &block)
      options = args.extract_options!
      
      model_name  = model.to_s.camelize
      options[:by]            ||= :company
      options[:scope_function]  ||= "current_#{options[:by]}"

      helper_name   = "#{model}_bound_by_#{options[:by]}"

      self.class_eval <<-"end_eval", __FILE__, __LINE__
          def #{helper_name}(&block)
            #{model_name}.bound_by_#{options[:by]}(#{options[:scope_function]}.id, &block)
          end
          
          alias_method :bound_by_#{options[:by]}, :#{helper_name}
      end_eval
    end
  end
end
