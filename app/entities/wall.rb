module Entities
  class Wall < StaticEntity
    def initialize(opts={})
      super
      @path = 'sprites/wall.png'
    end

    def blocking?
      true
    end
  end
end