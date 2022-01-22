--------------------------Window Creation--------------------------
window_width=1300
window_height=750
--------------------------Player Creation--------------------------
player={}
player.width=32
player.height=72
player.x=300
player.y=600
player.speed=500
player.health=10
player.max_health=10
---------------------------Bullet Storage---------------------------
all_bullets={}
----------------------------Enemy Storage---------------------------
all_enemy={}
-----------------------Randomise Enemy Spawns-----------------------
math.randomseed(os.time())
---------------------------Bullet Creation--------------------------
function createbullet()
  local bullet={}
  bullet.width=5
  bullet.height=10
  bullet.x=player.x+(player.width/2)-(bullet.width/2)
  bullet.y=player.y-bullet.height
  bullet.speed=400
  return (bullet)
end
----------------------------Enemy Creation--------------------------
function create_enemy()
  local enemy={}
  enemy.width=60
  enemy.height=60
  enemy.x=math.random(0,900-enemy.width)
  enemy.y=0
  enemy.speed=300
  return (enemy)
end
------------------------------Collision-----------------------------
function collision(v,k)
  return v.x<k.x+k.width and
         v.x+v.width>k.x and
         v.y<k.y+k.height and
         v.y+v.height>k.y
end

-------------------------love.load Function-------------------------
function love.load()
  love.window.setMode(window_width,window_height)
  timer=0
  enemy_timer=0
  score=0
  state="home"
  -------------------------------Images-----------------------------
  background=love.graphics.newImage('Images/bg.jpg')
  player_image=love.graphics.newImage('Images/canon.png')
  menu=love.graphics.newImage('Images/menu.jpg')
  enemy_image=love.graphics.newImage('Images/zombie.png')
  main_menu=love.graphics.newImage('Images/end.jpg')
  home_screen=love.graphics.newImage('Images/home menu.jpg')
  ---------------------------Audio File-----------------------------
  music=love.audio.newSource('Audio/Music.mp3',"stream")
  -------------------------------Font-------------------------------
  font=love.graphics.newFont('Font/font.ttf',30)
  love.graphics.setFont(font)
end
----------------------------Main Screen-----------------------------
function love.keypressed(key)
  if(key=="return" and state=="end")then
    state="home"
  elseif(key=="return" and state=="home")then
    state="play"
  end
end

------------------------love.update Function------------------------
function love.update(dt)
   -----------------------------Music-------------------------------
   music:play()
   music:setLooping(true)
  if (state=="play") then
   ---------------------------Update Timer--------------------------
   timer=timer+dt
   -----------------------Enemy Timer Update------------------------
   enemy_timer=enemy_timer+dt
   ------------------------------Keys-------------------------------
   if(love.keyboard.isDown('a'))then
     player.x=player.x-player.speed*dt
   end
   if(love.keyboard.isDown('d'))then
     player.x=player.x+player.speed*dt
   end
   ----------------------Player Movement Limits---------------------
   if(player.x<0)then
     player.x=0
   end
   if(player.x>900-player.width)then
     player.x=900-player.width
   end
   --------------------------Spawn Bullets--------------------------
   if(timer>0.1)then
     table.insert(all_bullets,createbullet())
     timer=0
   end
   ---------------------------Bullet Speed--------------------------
   for k,v in pairs(all_bullets)do
     v.y=v.y-v.speed*dt
   end
   -----------------------Delete Used Bullets-----------------------
   for k,v in pairs(all_bullets)do
     if(v.y<-v.height)then
       table.remove(all_bullets,k)
     end
   end
   --------------------------Spawn Enemies--------------------------
   if(enemy_timer>0.4)then
     table.insert(all_enemy,create_enemy())
     enemy_timer=0
   end
   ---------------------------Enemy Speed---------------------------
   for k,v in pairs(all_enemy)do
     v.y=v.y+v.speed*dt
   end
   --------------------------Delete Enemies-------------------------
   for k,v in pairs(all_enemy) do
    if (v.y>window_height+50) then
     table.remove(all_enemy,k)
     player.health=player.health-1
    end
   end
   -----------------Collision of Bullets andEnemies-----------------
   for k,v in pairs(all_bullets)do
     for keys,values in pairs(all_enemy)do
       if(collision(v,values))then
         table.remove(all_enemy,keys)
         table.remove(all_bullets,k)
         -----------------------Score update------------------------
         score=score+1
       end
     end
   end
   -----------------------------Game over----------------------------
   if(player.health==0)then
     state="end"
   end
  elseif (state=="end") then
   all_enemy={}
   all_bullets={}
   player.health=player.max_health
  elseif (state=="home") then
   all_enemy={}
   all_bullets={}
   player.health=player.max_health
  end
end

--------------------------love.draw Function-------------------------
function love.draw()
  if(state=="play")then
    love.graphics.draw(background)
    love.graphics.draw(menu,900,0)
    love.graphics.draw(player_image,player.x,player.y)
    for k,v in pairs(all_bullets)do
      love.graphics.rectangle("fill",v.x,v.y,v.width,v.height)
    end
    for k,v in pairs(all_enemy)do
      love.graphics.draw(enemy_image,v.x,v.y)
    end
    love.graphics.print(score,1090,510)
    love.graphics.setColor(0,1,0)
    love.graphics.rectangle("fill",1000,235,20*player.health,20)
    love.graphics.setColor(1,1,1)
    -----------------------------Game Over---------------------------
  elseif(state=="end")then
    love.graphics.draw(main_menu)
    love.graphics.setColor(0,0,0)
    love.graphics.print("SCORE:",490,200)
    love.graphics.print(score,680,200)
    love.graphics.print("Game Over",470,300)
    love.graphics.print("Press ENTER to to START",300,400)
    love.graphics.print("Press ESC to Quit ",360,500)
    love.graphics.setColor(1,1,1)
    ------------------------Main Screen Display----------------------
  elseif(state=="home")then
    love.graphics.draw(home_screen,0,0)
  end
end
