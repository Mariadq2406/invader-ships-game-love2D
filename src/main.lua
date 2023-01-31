function love.load()

-- Estado 0 menú; estado 1 juego; estado 2 pantalla de Game Over 
state = 0 

-- Puntos
score = 0
highscore = 0

-- Se crea un archivo .txt para guardar los puntos --
if not love.filesystem.getInfo("highscore.txt") then
  love.filesystem.write("highscore.txt", "0\n")
end
for line in love.filesystem.lines("highscore.txt") do
  highscore = tonumber(line)
end

-- Tiempo entre cada spawn de enemigos en segundos
spawn_rate = 2
timer = 0

-- Fondo --
wallpaper = love.graphics.newImage("assets/images/wallpaper.png")

-- Fuentes
fonts = {}
fonts.xxl = love.graphics.newFont("assets/fonts/Pixeled.ttf", 50)
fonts.xl = love.graphics.newFont("assets/fonts/Pixeled.ttf", 15)
fonts.md = love.graphics.newFont("assets/fonts/Pixeled.ttf", 10)

-- Música de fondo y efectos de sonido
soundtrack = love.audio.newSource("assets/audio/soundtrack.mp3", "static")
soundtrack:setLooping(true)
love.audio.play(soundtrack)
gameover = love.audio.newSource("assets/audio/gameover.mp3", "static")
gameover:setLooping(true)
sound_shoot = love.audio.newSource("assets/audio/shoot.ogg", "static")
sound_explo = love.audio.newSource("assets/audio/burst.ogg", "static")

-- HP
HP = 100

-- Jugador y enemigos
player = { x = 200, y = 510, speed = 180, img = love.graphics.newImage("assets/images/player.png") }
  enemies = {}
  for i = 1, 5 do
    local enemy = { x = math.random(0, 600), y = 10, speed = 50, img = love.graphics.newImage("assets/images/enemy.png") }
    table.insert(enemies, enemy) 
  shoots = {}
end
 
function love.update(dt)

  if state == 1 then

  for i, enemy in ipairs(enemies) do
    enemy.y = enemy.y + (enemy.speed * dt)
    -- Verifica si el enemigo ha cruzado el borde inferior
    if enemy.y > love.graphics.getHeight() then
      HP = HP - 10
      -- Resta una vida
      enemy.y = 10 -- Reinicia la posición del enemigo
      if HP <= 1 then 
        soundtrack:stop()
        love.audio.play(gameover)
          state = 2
      end
    end
  end

  timer = timer + dt
  if timer > spawn_rate then
    local enemy = { x = math.random(0, 600), y = 10, speed = 50, img = love.graphics.newImage("assets/images/enemy.png") }
    table.insert(enemies, enemy)
    timer = 0
  end

  -- Mover la nave del jugador
  if love.keyboard.isDown("right") then
    player.x = math.min(player.x + player.speed * dt, love.graphics.getWidth() - player.img:getWidth() - 10)
  elseif love.keyboard.isDown("left") then
    player.x = math.max(player.x - player.speed * dt, 10)
  end
  if love.keyboard.isDown("up") then
    player.y = math.max(player.y - player.speed * dt, 300)
  elseif love.keyboard.isDown("down") then
    player.y = math.min(player.y + player.speed * dt, love.graphics.getHeight() - player.img:getHeight() - 10)
  end

  -- Mover los enemigos y detectar colisiones con las balas
  for i, enemy in ipairs(enemies) do
    enemy.y = enemy.y + (enemy.speed * dt)

    if enemy.y > 600 then
      table.remove(enemies, i)
    end

    for j, shoot in ipairs(shoots) do
      if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), shoot.x, shoot.y, shoot.img:getWidth(), shoot.img:getHeight()) then
        table.remove(enemies, i)
        table.remove(shoots, j)
        sound_explo:play()
        score = score + 100
        if score > highscore then
          highscore = math.floor(score + 0.8)
      end
      end
    end
  end

  -- Mover las balas
  for i, shoot in ipairs(shoots) do
    shoot.y = shoot.y - (shoot.speed * dt)

    if shoot.y < 0 then
      table.remove(shoots, i)
    end
  end
end

  -- Comprobar colisiones entre la nave del jugador y las naves enemigas
  for i, enemy in ipairs(enemies) do
    if CheckCollision(player.x, player.y, player.img:getWidth(), player.img:getHeight(), enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight()) then
      -- Acción a realizar en caso de colisión, finalizar el juego
      HP = HP - 5
                if HP <= 1 then 
                  soundtrack:stop()
                  love.audio.play(gameover)
                    state = 2
                end
    end
  end
  love.filesystem.write("highscore.txt", highscore)
end

function love.keypressed(key)

  if key == "return" then
    if state == 0 then
        state = 1
        score = 0
        HP = 100
    end
  end
  
  if key == "escape" then
		love.event.quit()
	end

  if key == "space" then
    sound_shoot:play()
    local shoot = { x = player.x + player.img:getWidth() / 2, y = player.y, speed = 200, img = love.graphics.newImage("assets/images/shoot.png") }
    table.insert(shoots, shoot)
  end
end

function love.draw()

love.graphics.draw(wallpaper,0,0)

-- Dibujar jugador, enemigos y balas
  if state == 1 then
  love.graphics.draw(player.img, player.x, player.y)

  for _, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
  end

  for _, shoot in ipairs(shoots) do
    love.graphics.draw(shoot.img, shoot.x, shoot.y)
  end
end

--Dibujar mensajes en pantalla
if state == 0 then
  love.graphics.setFont(fonts.xxl)
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("INVADER SHIPS", 0, 150, 800, "center")
  love.graphics.setFont(fonts.xl)
  love.graphics.setColor(0, 1, 1)
  love.graphics.printf("press enter to start", 0, 280, 800, "center")
elseif state == 1 then
  love.graphics.setFont(fonts.md)
  love.graphics.setColor(0, 1, 1)
  love.graphics.print("SCORE: " ..score, 10, 10)
  love.graphics.print("HIGHSCORE: " ..highscore, 10, 42)
  love.graphics.print("HP: ", 650, 10)
  love.graphics.setColor(1, 0, 1)
  love.graphics.rectangle("fill",680, 15, HP, 20)
elseif state == 2 then
  love.graphics.setFont(fonts.xxl)
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("GAME OVER", 0, 150, 800, "center")
  love.graphics.setFont(fonts.xl)
  love.graphics.setColor(0, 1, 1)
  love.graphics.printf("press esc to exit", 0, 280, 800, "center")
end

-- Funcion
love.graphics.setColor(1, 1, 1)
end
function CheckCollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)
  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end
end