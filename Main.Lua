-- [[ Variables ]] -- 
local AnimationFolder = game.ReplicatedStorage.Assets.Animations

local AnimationStorage = {}

-- [[ Services ]] -- 
local RunService = game:GetService("RunService")
local MaidClass = require(game.ReplicatedStorage.Modules.Utils.MaidClass)

-- [[ Module ]] -- 
local AnimationHandler = {}
AnimationHandler.__index = AnimationHandler

-- Creates a new animation handler class if needed. If not it returns the humanoids loaded animation class.
function AnimationHandler.new(Humanoid)
	
	-- Pre-check
	if AnimationStorage[Humanoid] then return AnimationStorage[Humanoid] end
	
	-- Class initializer
	local NewClass = {}
	setmetatable(NewClass, AnimationHandler)
	
	NewClass.Humanoid = Humanoid
	NewClass.Tracks = {}
	NewClass.Queued = {}
	NewClass.AnimationPlaying = false
	NewClass.Maid = MaidClass.new()
	
	-- Loads tracks onto humanoid
	for i, Animation in pairs(AnimationFolder:GetDescendants()) do
		if Animation:IsA("Animation") then
			NewClass.Tracks[Animation.Name] = Humanoid:LoadAnimation(Animation)
		end
	end
	AnimationStorage[Humanoid] = NewClass
	
	-- Class connections / events
	NewClass.Maid["QueueHandler"] = RunService.Heartbeat:Connect(function()
		if #NewClass.Queued == 0 then return end
		local Track = NewClass.Queued[1]
		Track:Play()
		wait(Track.Length)
		NewClass.Queued[1] = nil
	end)
	
	NewClass.Maid["HumanoidCheck"] = Humanoid.Died:Connect(function()
		NewClass.Maid:DoCleaning()
		AnimationStorage[Humanoid] = nil
	end)
	
	return NewClass
	
end

-- Queues animations (Waits for previous animations to finish)
function AnimationHandler:QueueAnimation(AnimationName)
	
	local AnimationClass = AnimationStorage[self.Humanoid]
	if not AnimationClass then return end
	local Track = AnimationClass.Tracks[AnimationName]
	if not Track then return end
	
	table.insert(self.Queued, Track)
	
end

-- Quick plays the animation without worrying about queue or overlap. (Recommended for non-action animations)
function AnimationHandler:QuickPlay(AnimationName)
	
	local AnimationClass = AnimationStorage[self.Humanoid]
	if not AnimationClass then return end
	local Track = AnimationClass.Tracks[AnimationName]
	if not Track then return end

	Track:Play()
	
end

-- Stops any animation.
function AnimationHandler:StopAnimation(AnimationName)
	
	local AnimationClass = AnimationStorage[self.Humanoid]
	if not AnimationClass then return end
	local Track = AnimationClass.Tracks[AnimationName]
	if not Track then return end 
	
	Track:Stop()
	
end

return AnimationHandler
