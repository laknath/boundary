module Boundary
  module Controller
    # Adds a scope helper that call the model with a given parameter (ie: subdomain)
    #
    # Options:
    # * <tt>:to</tt> - Target scope model name (default: :company)
    # * <tt>:using</tt> - A function that returns the object used for scoping. This object should contain an ID column that matches with the foreign_id column of the scoped object (default: :current_company)
    #
    # use_scope_in :subscription, :to => :account, :using => :current_employee
    #
    # In your actions,
    #
    # def show
    #   @subscription = scoped_by_account { Subscription.find(params) }
    #   ...
    # end
    #
    # For multiple scopes,
    #
    # use_scope_in  :subscription, :to => :account, :using => :current_employee
    # use_scope_in  :transaction, :to => :account, :using => :current_employee
    #
    # def show
    #   @subscription = subscription_scoped_by_account { Subscription.find(params) }
    #   @transaction  = transaction_scoped_by_account { Transaction.find(params) }
    # end
    def use_scope_in(model, *args, &block)
      options = args.extract_options!
      
      model_name  = model.to_s.camelize
      options[:to]      ||= :company
      options[:using]   ||= "current_#{options[:to]}"

      helper_name   = "#{model}_scoped_by_#{options[:to]}"

      self.class_eval <<-"end_eval", __FILE__, __LINE__
          def #{helper_name}(&block)
            #{model_name}.scoped_by_#{options[:to]}(#{options[:using]}.id, &block)
          end
          
          alias_method :scoped_by_#{options[:to]}, :#{helper_name}
      end_eval
    end
  end
end
