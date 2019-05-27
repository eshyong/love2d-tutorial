player = {
    x = 200,
    y = 710,
    speed = 225,
    image = nil
}
isAlive = true
score = 0

-- Bullet variables
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax
bulletImage = nil
bullets = {}

-- Enemy variables
createEnemyTimerMax = 2.0
createEnemyTimer = createEnemyTimerMax
enemyImage = nil
enemies = {}

-- Update methods
local function restart()
    bullets = {}
    enemies = {}
    canShootTimer = canShootTimerMax
    createEnemyTimer = createEnemyTimerMax
    player.x = 50
    player.y = 710
    score = 0
    isAlive = true
end

local function updatePlayer(dt)
    local screenWidth = love.graphics.getWidth()
    local playerWidth = player.image:getWidth()
    local bulletWidth = bulletImage:getWidth()

    -- Move player left or right
    if love.keyboard.isDown('left', 'a') then
        player.x = player.x - (player.speed * dt)
    elseif love.keyboard.isDown('right', 'd') then
        player.x = player.x + (player.speed * dt)
    end

    -- Keep player within screen boundaries
    if player.x < 0 then
        player.x = 0
    elseif player.x + playerWidth > screenWidth then
        player.x = screenWidth - playerWidth
    end

    -- Create some bullets
    if love.keyboard.isDown('space') and canShoot then
        newBullet = {
            x = player.x + (playerWidth / 2) - (bulletWidth / 2),
            y = player.y,
            image = bulletImage,
        }
        table.insert(bullets, newBullet)
        canShoot = false
        canShootTimer = canShootTimerMax
    end
end

local function updateBullets(dt)
    -- Update the positions of bullets
    for i, bullet in ipairs(bullets) do
        bullet.y = bullet.y - (250 * dt)

        if bullet.y < 0 then
            table.remove(bullets, i)
        end
    end

    -- Time out how far apart our shots can be
    canShootTimer = canShootTimer - (1 * dt)
    if canShootTimer < 0 then
        canShoot = true
    end
end

local function updateEnemies(dt)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    for i, enemy in ipairs(enemies) do
        enemy.y = enemy.y + (100 * dt)

        local enemyHeight = enemyImage:getHeight()
        if enemy.y > screenHeight + enemyHeight then
            table.remove(enemies, i)
        end
    end

    -- Spawn enemies randomly
    createEnemyTimer = createEnemyTimer - (1 * dt)
    if createEnemyTimer < 0 then
        createEnemyTimer = math.random(0.5, 1.0) * createEnemyTimerMax

        randomNumber = math.random(10, screenWidth - 10)
        newEnemy = {
            x = randomNumber,
            y = -10,
            image = enemyImage,
        }
        table.insert(enemies, newEnemy)
    end
end

local function checkCollision(entity1, entity2)
    x1, y1, w1, h1 = entity1.x, entity1.y, entity1.image:getWidth(), entity1.image:getHeight()
    x2, y2, w2, h2 = entity2.x, entity2.y, entity2.image:getWidth(), entity2.image:getHeight()
    return (
            x1 < x2 + w2 and x2 < x1 + w1 and
                    y1 < y2 + h2 and y2 < y1 + h1
    )
end

local function checkForCollisions()
    for i, enemy in ipairs(enemies) do
        for j, bullet in ipairs(bullets) do
            if checkCollision(bullet, enemy) then
                table.remove(enemies, i)
                table.remove(bullets, j)
                score = score + 1
            end
        end

        if checkCollision(enemy, player) and isAlive then
            table.remove(enemies, i)
            isAlive = false
        end
    end
end

-- Main love callbacks
function love.load()
    player.image = love.graphics.newImage('assets/plane.png')
    bulletImage = love.graphics.newImage('assets/bullet.png')
    enemyImage = love.graphics.newImage('assets/enemy.png')
end

function love.update(dt)
    -- Check for quit key
    if love.keyboard.isDown('escape', 'q') then
        love.event.push('quit')
    end

    if isAlive then
        updatePlayer(dt)
        updateEnemies(dt)
        updateBullets(dt)
        checkForCollisions(dt)
    else
        if love.keyboard.isDown('r') then
            restart()
        end
    end
end

function love.draw()
    if isAlive then
        love.graphics.draw(player.image, player.x, player.y)
    else
        love.graphics.print(
                "Press 'R' to restart",
                love.graphics.getWidth() / 2 - 50,
                love.graphics.getHeight() / 2 - 10
        )
    end

    for _, bullet in ipairs(bullets) do
        love.graphics.draw(bullet.image, bullet.x, bullet.y)
    end

    for _, enemy in ipairs(enemies) do
        love.graphics.draw(enemy.image, enemy.x, enemy.y)
    end
end
