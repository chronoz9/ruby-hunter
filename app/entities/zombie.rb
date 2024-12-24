module Entities
  class Zombie < Enemy
    def initialize(opts = {})
      super
      @path = 'sprites/hexagon/black.png'
    end
  end
end