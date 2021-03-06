local world = require('world')
local constant = require('constant')
local input = require('input')
local laser = require('entities/laser')

-- Player
return function(img)
	local player = {
		speed = 600,
		pos = { x = 0, y = 0 },
		dimension = { width = 0, height = 0 },
		-- We need to set these default tables or lua gets picky
		lasers = {}
	}

	player.img = img
	-- The values are from the XML file of the spritesheet
	player.quad = love.graphics.newQuad(211, 941, 99, 75, player.img:getDimensions())

	-- These are the initial player position, do NOT use later. Use body positon.
	player.pos.x, player.pos.y, player.dimension.width, player.dimension.height = player.quad:getViewport()
	player.pos.x = love.graphics.getWidth() / constant.HALF
	player.pos.y = love.graphics.getHeight() * constant.PLAYER_POS_Y

	player.body = love.physics.newBody(world, player.pos.x, player.pos.y, 'dynamic')
	player.body:setMass(100)
	player.shape = love.physics.newRectangleShape(player.dimension.width, player.dimension.height)
	player.fixture = love.physics.newFixture(player.body, player.shape)

	-- Set fixture ID
	player.fixture:setUserData('player')

	player.shoot = function(self)
		table.insert(
			self.lasers,
			laser(
				self.img,
				self.body:getX(),
				self.body:getY() - self.dimension.height
			)
		)
	end

	player.draw = function(self)
		-- Hit box
		love.graphics.polygon('line', self.body:getWorldPoints(self.shape:getPoints()))
		-- Sprite
		love.graphics.draw(
			self.img,
			self.quad,
			self.body:getX(),
			self.body:getY(),
			0,
			1,
			1,
			self.dimension.width / constant.HALF,
			self.dimension.height / constant.HALF
		)

		for i, laser in ipairs(self.lasers) do
			laser:draw()
		end
	end

	player.update = function(self)
		-- Don't move if both keys are been pressed
		if input.buttonLeft and input.buttonRight then
			return
		end

		-- Move left or right
		if input.buttonLeft then
			self.body:setLinearVelocity(-self.speed, 0)
		elseif input.buttonRight then
			self.body:setLinearVelocity(self.speed, 0)
		else
			self.body:setLinearVelocity(0, 0)
		end

		for i, laser in ipairs(self.lasers) do
			if laser.dead then
				laser.fixture:destroy()
				laser.body:destroy()
				table.remove(self.lasers, i)
			else
				laser:update()
			end
		end

		if input.buttonUp then
			self:shoot()
		end
	end

	return player
end
