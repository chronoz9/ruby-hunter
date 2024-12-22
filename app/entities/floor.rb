module Entities
  class Floor < StaticEntity
    def initialize(opts = {})
      super
      @path = 'sprites/floor.png'
    end
  end
end