# frozen_string_literal: true

require 'dry/configurable/setting'
require 'dry/configurable/settings'

module Dry
  module Configurable
    # Setting compiler used internally by the DSL
    #
    # @api private
    class Compiler
      def call(ast)
        Settings.new.tap do |settings|
          ast.each do |node|
            setting = visit(node)
            settings[setting.name] = setting
          end
        end
      end

      # @api private
      def visit(node)
        type, rest = node
        public_send(:"visit_#{type}", rest)
      end

      # @api private
      def visit_constructor(node)
        setting, constructor = node
        visit(setting).with(constructor: constructor)
      end

      # @api private
      def visit_setting(node)
        name, value, opts = node
        Setting[name, **opts, value: value, default: value]
      end

      # @api private
      def visit_nested(node)
        parent, children = node
        visit(parent).with(settings: Compiler.new.(children))
      end
    end
  end
end
