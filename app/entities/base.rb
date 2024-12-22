module Entities
  class Base
    attr_sprite

    SPRITE_WIDTH = 32
    SPRITE_LENGTH = 32

    def initialize(opts = {})
      @x = opts[:x] || 0
      @y = opts[:y] || 0
      @w = opts[:w] || SPRITE_WIDTH
      @h = opts[:h] || SPRITE_HEIGHT
      @path = opts[:path] || 'app/sprites/null_sprite.png'
    end
  end
end