module Entities
  class Base
    attr_sprite
    attr_reader :map_x, :map_y

    SPRITE_WIDTH = 32
    SPRITE_HEIGHT = 32

    def initialize(opts = {})
      @map_x = opts[:map_x] || 0
      @map_y = opts[:map_y] || 0
      @x = map_x
      @y = map_y
      @w = opts[:w] || SPRITE_WIDTH
      @h = opts[:h] || SPRITE_HEIGHT
      @path = opts[:path] || 'app/sprites/null_sprite.png'
    end

    def serialize
      {
        x: x,
        y: y,
        w: w,
        h: h,
        path: path,
        blocking: blocking?
      }
    end

    def blocking?
      false
    end
  end
end