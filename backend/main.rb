require "./services/repository"
require "./serializers/worker"
require "./models/price"

module Backend
  class Main
    DEFAULTS_OPTS = {
      discount: false, commission: false, deductible: false, serializer: :base
    }.freeze

    def self.perform(data, opts = {})
      new(data, opts).perform
    end

    attr_reader :repo, :opts
    delegate :rentals_with_car, to: :repo

    def initialize(data, opts)
      @opts = opts
      @repo = Services::Repository.new(data)
    end

    def perform
      { rentals: rental_serializers.map(&:as_json) }.to_json
    end

    private

    def rental_serializers
      rentals_with_car.map do |rental_with_car|
        Serializers::Worker.setup(
          rental: rental_with_car[:rental],
          price: ::Models::Price.new(rental_with_car, opts),
          opts: opts
        )
      end
    end
  end
end
