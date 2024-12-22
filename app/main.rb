HIGH_SCORE_FILE='high-score.txt'
GAME_TIME=30

def spawn_target(args)
  size = 42
  {
    x: rand(args.grid.w * 0.4 - size) + args.grid.w * 0.6,
    y: rand(args.grid.h - size * 2) + size,
    w: size,
    h: size,
    dead: false,
    path: 'sprites/target.png',
    angle: 0
  }
end

def detect_collision(args, bullet, target)
  if args.geometry.intersect_rect?(target, bullet)
    target.angle_anchor = 5
    target.dead = true
    bullet.dead = true
    args.state.score += 1
    args.state.targets << spawn_target(args)
    args.outputs.sounds << 'sounds/target.wav'
    args.state.explosions << explosion_obj(args, target.x, target.y)
  end
end

def validate_boundaries(args)
  if !args.state.player.x.between?(0,args.grid.w-args.state.player.w)
    args.state.player.x = args.state.player.x < 0 ? 0 : args.grid.w - args.state.player.w
  end

  if !args.state.player.y.between?(0,args.grid.h-args.state.player.h)
    args.state.player.y = args.state.player.y < 0 ? 0 : args.grid.h - args.state.player.h
  end
end

def player_movement(args)
  args.state.player.x += args.state.player.speed * args.inputs.left_right
  args.state.player.y += args.state.player.speed * args.inputs.up_down
end

def player_moving?(args)
  input = args.inputs
  return false if input.up_down.zero? && input.left_right.zero?

  true
end

def game_timer(args)
  fps = 60
  args.state.timer ||= GAME_TIME*fps

  args.state.timer -= 1
end

def timer_label(args)
  {x: 2, y: args.grid.h - 20, text: "timer: #{(args.state.timer/60).round}", size_enum: 0}
end

def fire_input?(args)
  args.inputs.keyboard.key_down.space
end

def fireball_obj(args)
  {
    x: args.state.player.x + 45,
    y: args.state.player.y - 35,
    w: 127, h: 125,
    dead: false,
    path: 'sprites/fireball.png',
    flip_vertical: true
  }
end

def star_obj(args, offset=0)
  # size = Numeric.rand(4..16)
  if Numeric.rand(0..10) % 2 == 0
    size = 16
    is_tiny = ''
  else
    size = 4
    is_tiny = 'tiny-'
  end
  {
    x: Numeric.rand(0..args.grid.w*2) + offset,
    y: Numeric.rand(0..args.grid.h),
    w: size,
    h: size,
    path: "sprites/misc/#{is_tiny}star.png"
    # r:255,g:255,b:255
  }
end

def background_obj(args)
  {
    x: 0,
    y: 0,
    w: args.grid.w,
    h: args.grid.h,
    r: 92,
    g: 120,
    b: 230,
  }
end

def generate_stars(args, number=200, x_offset=0)
  stars = []
  number.times do |t|
    stars << star_obj(args, x_offset)
  end

  stars
end

def initiate_background(args)
  args.state.stars ||= generate_stars(args)
  args.outputs.solids << [
    background_obj(args)
  ]
  args.outputs.sprites << args.state.stars
end

def initiate_player(args)
  args.state.player ||= {
    x: 60,
    y: 60,
    speed: 10,
    w: 100,
    h: 80,
    angle: 0
  }

  player_sprite_index = 0.frame_index(count: 6, hold_for: player_moving?(args) ? 3 : 8, repeat: true)
  args.state.player.path = "sprites/misc/dragon-#{player_sprite_index}.png"

end

def explosion_obj(args, x, y)
  {
    x: x,y: y,
    w:42,h:42,
    tile_w: 32,
    tile_h: 32,
    tile_x: 0,
    tile_y: 0,
    path:'sprites/misc/explosion-sheet.png'
  }
end

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=

def title_tick(args)
  initiate_background(args)
  initiate_player(args)
  if args.state.player.x > args.grid.w
    args.state.player.x = -50
  else
    args.state.player.x += 3
  end

  args.outputs.sprites << args.state.player
  args.outputs.labels << [
    {x: args.grid.w/2, y: args.grid.h/2, text: 'FLIGHT of RUBY', size_enum: 20},
    {x: args.grid.w/2, y: args.grid.h/2-120, text: 'Press [space] to start!', size_enum: 10},

  ]

  if fire_input?(args)
    args.state.scene = 'gameplay'
  end

end

def gameplay_tick(args)
  game_timer(args)
  initiate_player(args)
  initiate_background(args)
  args.state.explosion ||= {}
  args.state.explosions ||= []

  if args.state.timer == 0
    args.outputs.sounds << 'sounds/game-over.wav'
    args.audio[:music].paused = true
    args.state.scene = 'game_over'

  end


  args.state.targets.each do |t|
    t.angle += 1
  end

  args.state.stars.each do |star|
    star.x -= 1
  end

  args.state.fireballs ||= []


  args.state.targets ||= [
    spawn_target(args),
    spawn_target(args)
  ]
  args.state.score ||= 0

  player_movement(args)

  validate_boundaries(args)

  if fire_input?(args)
    args.outputs.sounds << 'sounds/fireball.wav'
    args.state.fireballs << fireball_obj(args)
  end

  args.state.fireballs.each do |fb|
    fb.x += args.state.player.speed * 4

    if fb.x > args.grid.w
      fb.dead = true
      next
    end

    args.state.targets.each do |target|
      detect_collision(args, fb, target)
    end
  end

  args.state.explosions.each do |exp|
    explosion_sprite_index = 0.frame_index(count: 7, hold_for: 6, repeat: true)

    exp.tile_x = explosion_sprite_index.to_i * 32

    if explosion_sprite_index == 6
      exp.dead = true
    end
  end

  args.state.explosions.reject!(&:dead)
  args.state.targets.reject!{|t| t.dead}
  args.state.fireballs.reject!{|fb| fb.dead}
  args.outputs.labels << [{
    x: 3,
    y: args.grid.h - 3,
    text: "score: #{args.state.score}",
    size_enum: 0
  }, timer_label(args)
  ]

  args.outputs.sprites << [args.state.player, args.state.fireballs, args.state.targets, args.state.explosions]

end

def game_over_tick(args)
  args.state.timer -= 1

  args.state.high_score ||= args.gtk.read_file(HIGH_SCORE_FILE).to_i

  if !args.state.saved_high_score && args.state.score > args.state.high_score
    args.gtk.write_file(HIGH_SCORE_FILE, args.state.score.to_s)
    args.state.saved_high_score = true
  end

  labels = []
  labels << {
    x: args.grid.w/2,
    y: args.grid.h/2,
    text: 'game over',
    size_enum: 0
  }


  if args.state.score > args.state.high_score
    labels << {
      x: 100,
      y: args.grid.h - 100,
      text: 'New high score!'
    }
  else
    labels << {
      x: 100,
      y: args.grid.h - 100,
      text: "score to beat: #{args.state.high_score}"
    }
  end

  args.outputs.labels << labels

  if fire_input?(args) && args.state.timer < -30
    $gtk.reset
  end

end

# ==============================================================================================
def tick args
  if args.state.tick_count == 1
    args.audio[:music] = {
      input: 'sounds/flight.ogg',
      looping: true
    }
  end

  args.state.scene ||= 'title'

  send("#{args.state.scene}_tick", args)
end

$gtk.reset