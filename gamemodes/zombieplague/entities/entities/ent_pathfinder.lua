AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

function ENT:Initialize()
	if CLIENT then return end

	self:SetModel("models/player.mdl")
	self:SetSolid(SOLID_NONE)
	self:SetNoDraw(true)
end

function ENT:SetEnemy(Enemy)
	self.Enemy = Enemy
end
function ENT:GetEnemy()
	return self.Enemy
end
function ENT:SetForgetEnemyTime(ForgetEnemyTime)
	self.ForgetEnemyTime = ForgetEnemyTime
end
function ENT:GetForgetEnemyTime()
	return self.ForgetEnemyTime
end
function ENT:SetTargetPos(TargetPos)
    self.TargetPos = TargetPos
	self:SetLastTargetPos(TargetPos)
end
function ENT:ResetTargetPos()
	self.TargetPos = nil
end
function ENT:GetTargetPos()
    return self.TargetPos
end
function ENT:SetLastTargetPos(LastTargetPos)
	self.LastTargetPos = LastTargetPos
end
function ENT:GetLastTargetPos()
	return self.LastTargetPos
end
function ENT:SetPath(Path)
	self.Path = Path
end
function ENT:SetStuckPlace(StuckPlace)
	-- Only set a new place if is different from the old one (With an error margin)
	if !self:GetStuckPlace() || self:GetStuckPlace().Pos:Distance2DSqr(self:GetPos()) > 50 then
		self.StuckPlace = StuckPlace
	end
end
function ENT:GetStuckPlace()
	return self.StuckPlace
end
function ENT:StuckInSamePlaceTime()
	if self.StuckPlace then
		return CurTime() - self.StuckPlace.InitialTime
	end

	return 0
end
function ENT:IsStuckInSamePlace()
	return self:StuckInSamePlaceTime() > 5
end
function ENT:GetPath()
	if !self.Path || !self.Path:IsValid() then
		local Path = Path("Chase")
		Path:SetMinLookAheadDistance(500)
		Path:SetGoalTolerance(20)

		self:SetPath(Path)
	end

	return self.Path
end
function ENT:GetCurrentSegment()
	local Segments = self:GetPath():GetAllSegments()

	return Segments and Segments[self:GetNextSegmentId() - 1] or nil
end
function ENT:GetNextSegment()
	local Segments = self:GetPath():GetAllSegments()

	return Segments and Segments[self:GetNextSegmentId()] or nil
end
function ENT:HasNextSegment()
	local Segments = self:GetPath():GetAllSegments()
	if !Segments then
		return false
	end

	return self:GetNextSegmentId() < #Segments
end
function ENT:SkipSegment()
	local Segments = self:GetPath():GetAllSegments()
	local NextSegmentId = self:GetNextSegmentId() + 1

	if NextSegmentId > #Segments then
		NextSegmentId = #Segments
	end

	self:SetNextSegmentId(NextSegmentId)
end
function ENT:SetNextSegmentId(NextSegmentId)
	self.NextSegmentId = NextSegmentId
end
function ENT:GetNextSegmentId()
	return self.NextSegmentId
end
function ENT:ComputePath(Path, TargetPosition)
	-- Put some logic that only recalculates if on a navmesh
	Path:Compute(self, TargetPosition)
	self:SetNextSegmentId(2)

	return Path:GetLength()
end
function ENT:SetKeys(Keys)
	self.Keys = Keys
end
function ENT:GetKeys()
	return self.Keys or 0
end
function ENT:SetNextJump(NextJump)
	self.NextJump = NextJump
end
function ENT:ShouldJump()
	if !self.NextJump then
		return true
	end

	if self.NextJump < CurTime() then
		return true
	end

	return false
end
function ENT:SetNextCrouch(NextCrouch)
	self.NextCrouch = NextCrouch
end
function ENT:ShouldCrouch()
	if !self.NextCrouch then
		return true
	end

	if self.NextCrouch < CurTime() then
		return true
	end

	return false
end
----------------------------------------------------
-- ENT:RunBehaviour()
-- This is where the meat of our AI is
----------------------------------------------------
function ENT:RunBehaviour()
	while(true) do
		if self:GetTargetPos() then
			self:ChaseTargetPos()
		end

		coroutine.yield()
	end
end	
function ENT:ChaseTargetPos()
	local Path = self:GetPath()
	self:ComputePath(Path, self:GetTargetPos())

	if (!Path:IsValid()) then
		return PATH_INVALID
	end

	while(self:GetTargetPos() && Path:IsValid()) do
		if(Path:GetAge() > 1) then
			self:ComputePath(Path, self:GetTargetPos())
		end

		if (self.loco:IsStuck()) then
			self:HandleStuck()
			return PATH_STUCK
		end

		coroutine.yield()
	end

	return PATH_OK
end
function ENT:Health()
	return nil
end
function ENT:OnKilled()
	return false
end
function ENT:OnInjured()
	return false
end
function ENT:IsNPC()
	return false
end
function ENT:IsInTargetPos()
	return self:GetLastTargetPos() and self:GetPos():Distance2D(self:GetLastTargetPos()) < 20 or false
end
function ENT:HasArrivedOnTargetPos()
	return self:GetPos():Distance2D(self:GetTargetPos()) < 20
end
function ENT:Think()
	local Owner = self:GetOwner()

	if Owner then
		if self:GetPos() != Owner:GetPos() then
			self:SetPos(Owner:GetPos())
		end
	
		if self:GetAngles() != Owner:EyeAngles() then
			self:SetAngles(Owner:EyeAngles())
		end
	end

	if self:GetTargetPos() && self:HasArrivedOnTargetPos() then
		self:ResetTargetPos()
	end
end