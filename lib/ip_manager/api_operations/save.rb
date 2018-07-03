module IpManager
  module APIOperations
    module Save
      module ClassMethods

        def update(id, params = {}, opts = {})
          raise(NotImplementedError, "Not Implemented")
        end
      end

      def save(params = {}, opts = {})
        raise(NotImplementedError, "Not Implemented")
      end

    end
  end
end
