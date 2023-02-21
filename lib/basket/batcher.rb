module Basket
  module Batcher
    module Options
      def self.included(base)
        base.extend(ClassMethods)
        base.basket_class_attribute :basket_options_hash
      end

      module ClassMethods
        ACCESSOR_MUTEX = Mutex.new

        def basket_options(opts = {})
          # opts = opts.transform_keys(&:to_s) # stringify
          self.basket_options_hash = get_basket_options.merge(opts)
        end

        def get_basket_options
          basket_options_hash || {}
        end

        def basket_class_attribute(*attrs)
          instance_reader = true
          instance_writer = true

          attrs.each do |name|
            synchronized_getter = "__synchronized_#{name}"

            singleton_class.instance_eval do
              undef_method(name) if method_defined?(name) || private_method_defined?(name)
            end

            define_singleton_method(synchronized_getter) { nil }
            singleton_class.class_eval do
              private(synchronized_getter)
            end

            define_singleton_method(name) { ACCESSOR_MUTEX.synchronize { send synchronized_getter } }

            ivar = "@#{name}"

            singleton_class.instance_eval do
              m = "#{name}="
              undef_method(m) if method_defined?(m) || private_method_defined?(m)
            end
            define_singleton_method("#{name}=") do |val|
              singleton_class.class_eval do
                ACCESSOR_MUTEX.synchronize do
                  undef_method(synchronized_getter) if method_defined?(synchronized_getter) || private_method_defined?(synchronized_getter)
                  define_method(synchronized_getter) { val }
                end
              end

              if singleton_class?
                class_eval do
                  undef_method(name) if method_defined?(name) || private_method_defined?(name)
                  define_method(name) do
                    if instance_variable_defined? ivar
                      instance_variable_get ivar
                    else
                      singleton_class.send name
                    end
                  end
                end
              end
              val
            end

            if instance_reader
              undef_method(name) if method_defined?(name) || private_method_defined?(name)
              define_method(name) do
                if instance_variable_defined?(ivar)
                  instance_variable_get ivar
                else
                  self.class.public_send name
                end
              end
            end

            if instance_writer
              m = "#{name}="
              undef_method(m) if method_defined?(m) || private_method_defined?(m)
              attr_writer name
            end
          end
        end
      end
    end

    def self.included(base)
      raise ArgumentError, "Basket::Batcher cannot be included in an ActiveJob: #{base.name}" if base.ancestors.any? { |c| c.name == "ActiveJob::Base" }

      base.include(Options)
      base.extend(ClassMethods)
    end

    def logger
    end

    module ClassMethods
      def basket_options(opts = {})
        super
      end
    end
  end
end
