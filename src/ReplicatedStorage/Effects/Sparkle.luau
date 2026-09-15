return {
	New = function()
		local random = Random.new()

		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "ParticleEmitter"
		particleEmitter.FlipbookFramerate = NumberRange.new(16)
		particleEmitter.FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4
		particleEmitter.Lifetime = NumberRange.new(1)
		particleEmitter.LightEmission = random:NextNumber(0.4, 0.6)
		particleEmitter.LightInfluence = random:NextNumber(0.7, 1)
		particleEmitter.LockedToPart = true
		particleEmitter.Rate = random:NextNumber(0.3, 0.5)
		particleEmitter.RotSpeed = NumberRange.new(-45, 45)
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0.5),
		})
		particleEmitter.Speed = NumberRange.new(0)
		particleEmitter.Texture = "http://www.roblox.com/asset/?id=13448020277"
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0.5),
		})
		particleEmitter.ZOffset = 1

		return particleEmitter
	end,
}
