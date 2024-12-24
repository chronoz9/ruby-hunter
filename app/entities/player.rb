module Entities
  class Player < MobileEntity
    attr :took_action

    def initialize(opts={})
      super
      @path = 'sprites/misc/dragon-0.png'
    end

    def tick(args)
      @took_action = false
      # @map_x += ::Controllers::MapController::TILE_WIDTH * args.inputs.left_right * 0.5
      # @map_y += ::Controllers::MapController::TILE_HEIGHT * args.inputs.up_down * 0.5
      # target_x = @map_x
      # target_y = @map_y
      # ::Controllers::MapController.tick(args)
      # @x = map_x - args.state.map.x
      # @y = map_y - args.state.map.y


      keyboard = args.inputs.keyboard
      target_x = if keyboard.key_down.right || keyboard.key_down.d
                  @map_x + ::Controllers::MapController::TILE_WIDTH
                elsif keyboard.key_down.left || keyboard.key_down.a
                  @map_x - ::Controllers::MapController::TILE_WIDTH
                else
                  @map_x
                end
      target_y = if keyboard.key_down.up || keyboard.key_down.w
                  @map_y + ::Controllers::MapController::TILE_HEIGHT
                elsif keyboard.key_down.down || keyboard.key_down.s
                  @map_y - ::Controllers::MapController::TILE_HEIGHT
                else
                  @map_y
                end
      attempt_move(args, target_x, target_y) do
        ::Controllers::MapController.tick(args)
        @took_action = true
      end


      # @y += args.inputs.up_down
      # @x += args.inputs.left_right
      # p args.inputs.up_down
      # @y += ::Controllers::MapController::MAP_HEIGHT if args.inputs.keyboard.key_down.up
      # @y -= ::Controllers::MapController::MAP_HEIGHT if args.inputs.keyboard.key_down.down
      # @x += ::Controllers::MapController::MAP_HEIGHT if args.inputs.keyboard.key_down.right
      # @x -= ::Controllers::MapController::MAP_HEIGHT if args.inputs.keyboard.key_down.left
      # attempt_move(args, target_x, target_y) do
      #   ::Controllers::MapController.tick(args)
      # end
    end
  end
end