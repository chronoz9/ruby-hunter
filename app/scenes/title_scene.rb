module Scenes
  class TitleScene
    def self.tick(args)
      $game.goto_game(args) if args.inputs.keyboard.space
    end

    def self.render(state, sprites, labels)
      labels << {x: 620, y: 300, text: 'Ruby Hunter'}
      labels << {x: 550, y: 100, text: 'Press space to start'}
      sprites << {x: 576, y: 500, w: 128, h: 101, path: 'sprites/ruby.png'}
    end
  end
end