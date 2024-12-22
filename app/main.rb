require 'app/requires.rb'

class Game
  attr_reader :active_scene

  def goto_title
    @active_scene = ::Scenes::TitleScene
  end

  def goto_game(args)
    ::Scenes::GameScene.reset(args.state)
    @active_scene = ::Scenes::GameScene
  end

  def tick(args)
    goto_title unless active_scene
    sprites = []
    labels = []
    active_scene.tick(args)
    active_scene.render(args.state, sprites, labels)

    render(args, sprites, labels)
  end

  def render(args, sprites, labels)
    args.outputs.sprites << sprites
    args.outputs.labels << labels
  end
end


$game ||= Game.new
def tick(args)
  $game.tick(args)
end
