module WhiplashApi
  class Shipnotice < Base
    class << self

      def status_for(status_code)
        status_mapping[status_code].to_s.titleize
      end
      def status_code_for(status)
        status_mapping.invert[status.to_s.underscore.to_sym]
      end

      def warehouse_for(warehouse_code)
        warehouse_mapping[warehouse_code].to_s.titleize
      end
      def warehouse_code_for(warehouse)
        warehouse_mapping.invert[warehouse]
      end

      def count(args={})
        self.get(:count, args)[:count]
      end

      def update(id, args={})
        response = self.put(id, {}, args.to_json)
        response.code.to_i >= 200 && response.code.to_i < 300
      rescue WhiplashApi::RecordNotFound
        raise RecordNotFound, "No Shipment notice found with given ID."
      end

      def delete(*args)
        super
      rescue WhiplashApi::RecordNotFound
        raise RecordNotFound, "No Shipment notice found with given ID."
      end

      private

      def status_mapping
        {
          25  => :unexpected,
          50  => :draft,
          100 => :in_transit,
          150 => :arrived,
          200 => :processing,
          250 => :problem,
          300 => :completed,
        }
      end

      def warehouse_mapping
        { 1 => "Ann Arbor", 2 => "San Francisco", 3 => "London" }
      end
    end

    # instance methods
    def received?
      self.status.to_i > 100
    end

    def processed?
      self.status.to_i > 200
    end

    def destroy
      self.class.delete(self.id)
    end
  end
end
