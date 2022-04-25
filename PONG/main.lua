
Class = require 'Class'
require 'Paddle'
require 'Ball'
--declarations
push = require 'push'

Src1 = love.audio.newSource("sound1.wav", "static")
Src2 = love.audio.newSource("sound2.wav", "static")

TitleFont = love.graphics.newFont('font.ttf', 40)
ScoreFont = love.graphics.newFont('font2.ttf', 25)
FPSFont = love.graphics.newFont('font3.ttf', 12)

--window size config
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 640
VIRTUAL_HEIGHT = 360

--player config
Player1Score = 0
Player2Score = 0
PaddleSpeed = 200
Player1Y = 30
Player2Y = VIRTUAL_HEIGHT - 70
ServingPlayer = 0
Winner = 0



function love.load()

    love.window.setTitle("PONG")

    love.graphics.setDefaultFilter("nearest", "nearest")

    --random
    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    Player1 = Paddle(10, 30, 5, 20)
    Player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    Ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    --gamestate
    GameState = 'start'

end

function love.keypressed(key)

    if key == "escape" then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        
        if GameState == 'start' then
            GameState = 'play'
        elseif GameState == 'serve' then
            if ServingPlayer == 1 then
                Ball.dx = math.abs(Ball.dx)
                GameState = 'play'
            else
                Ball.dx = -math.abs(Ball.dx)
                GameState = 'play'
            end
        else
            GameState = 'start'
            Ball:reset()
            
        end
    end

end


function love.draw()

    push:apply('start')

    --love.graphics.clear(255, 45, 52, 255)

    --title
    love.graphics.setFont(TitleFont)
    
    love.graphics.printf(
        "HELLO PONG",
        0,
        VIRTUAL_HEIGHT/2 - 100,
        VIRTUAL_WIDTH,
        "center"
        
    )

    love.graphics.setFont(ScoreFont)
    if GameState == 'serve' then
        love.graphics.printf(
        'Player'..tostring(ServingPlayer)..' serve',
        0,
        VIRTUAL_HEIGHT/2 - 50,
        VIRTUAL_WIDTH,
        "center")

    elseif GameState == 'gameover' then

        love.graphics.printf(
            GameState,
            0,
            VIRTUAL_HEIGHT/2 - 50,
            VIRTUAL_WIDTH,
            "center")

        love.graphics.printf(
        Winner..' is the winner',
        0,
        VIRTUAL_HEIGHT/2 + 50,
        VIRTUAL_WIDTH,
        "center")

    
    else
        love.graphics.printf(
            GameState,
            0,
            VIRTUAL_HEIGHT/2 - 50,
            VIRTUAL_WIDTH,
            "center")
    end

    --render left paddle
    Player1:render()

    --renderright paddle
    Player2:render()


    --render ball (center)
    Ball:render()
    
    --render score board
    love.graphics.setFont(ScoreFont)
    love.graphics.print(tostring(Player1Score), VIRTUAL_WIDTH / 2 - 50, 30)
    love.graphics.print(':', VIRTUAL_WIDTH / 2, 30)
    love.graphics.print(tostring(Player2Score), VIRTUAL_WIDTH / 2 + 40, 30)
    
    DisplayFPS()
    push:apply('end')
    

end

function love.update(dt)

    if GameState == 'gameover' then
        Ball:reset()
    end


    
    if GameState == 'play' then
        if Ball:collides(Player1) then
            Src1:play()
            Ball.dx = -Ball.dx * 1.15
            Ball.x = Player1.x + 5
            if Ball.dy < 0 then
                Ball.dy = -math.random(10, 150)
            else
                Ball.dy = math.random(10, 150)
            end
        end
        if Ball:collides(Player2) then
            Src1:play() 
            Ball.dx = -Ball.dx * 1.15
            Ball.x = Player2.x - 4

            if Ball.dy < 0 then
                Ball.dy = -math.random(10, 150)
            else
                Ball.dy = math.random(10, 150)
            end
        end
    end

    if Ball.y <= 0 then
        Ball.y = 0
        Ball.dy = -Ball.dy
    end

    if Ball.y >= VIRTUAL_HEIGHT - 4 then
        Ball.y = VIRTUAL_HEIGHT - 4
        Ball.dy = -Ball.dy
    end

    if Ball.x <= 0 then
        Src2:play()
        Player2Score = Player2Score + 1
        Ball:reset()
        GameState = 'serve'
        ServingPlayer = 1
    end

    if Ball.x >= VIRTUAL_WIDTH - 4 then
        Src2:play()
        Player1Score = Player1Score + 1
        Ball:reset()
        GameState = 'serve'
        ServingPlayer = 2
    end

    --left paddle movement
    if love.keyboard.isDown("w") then

        Player1.dy = -PaddleSpeed
        
    elseif love.keyboard.isDown("s") then

        Player1.dy = PaddleSpeed

    else

        Player1.dy = 0

    end


    Player1:update(dt)

    --right paddle movement
    if love.keyboard.isDown("up") then
        Player2.dy = -PaddleSpeed
    elseif love.keyboard.isDown("down") then
        Player2.dy = PaddleSpeed
    else
        Player2.dy = 0
    end

    Player2:update(dt)

    --render score

    --ball movement
    if GameState == 'play' then
        Ball:update(dt)
    end


    if Player1Score >= 5 then
        GameState = 'gameover'
        Winner = 'player1'
    elseif Player2Score >= 5 then
        GameState = 'gameover'
        Winner = 'player2'
    end
end



function DisplayFPS()
    love.graphics.setFont(FPSFont)
    love.graphics.setColor(0, 255, 255)
    love.graphics.print("FPS:  "..tostring(love.timer.getFPS()), 10, 10)
end






