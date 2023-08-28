local nodesFolder = workspace:FindFirstChild("Nodes") or workspace:WaitForChild("Nodes", 3)
local beamsFolder = workspace:FindFirstChild("CommutativeBeams") or workspace:WaitForChild("CommutativeBeams", 3)

local nodeParts = nodesFolder:GetChildren()


local function mainLoop()
	local nodes = {}
	local visitedNodes = {}
	local unvisitedNodes = {}
	local currentNode = nil
	
	-- Setup. Populate nodes dictionary.
	for _, part in ipairs(nodeParts) do
		for attr, _ in pairs(part:GetAttributes()) do
			local target: any = nodesFolder:FindFirstChild(attr)
			local dist = (part.Position - target.Position).Magnitude

			part:SetAttribute(attr, dist)
		end

		nodes[part.Name] = {
			['Distance'] = 9999,
			['Previous'] = nil,
			['Connections'] = part:GetAttributes()
		}
	end
	
	-- Starting node A, distance to = 0.
	nodes['A']['Distance'] = 0
	
	-- Populate unvisitedNodes.
	for k, v in pairs(nodes) do
		table.insert(unvisitedNodes, k)
	end
	
	local function _chooseNextMinimalDistance()
		local selectedNode = nil
		local curSmallestDist = 99999

		for k, v in pairs(nodes) do
			if table.find(unvisitedNodes, k) then
				local dist = v['Distance']

				if dist <= curSmallestDist then
					selectedNode = k
					curSmallestDist = dist
				end
			end
		end

		return selectedNode
	end


	local function _updateConnectedDistances()
		for k, v in pairs(nodes[currentNode]['Connections']) do
			if not table.find(visitedNodes, k) then
				local curDist = nodes[currentNode]['Distance']

				if (curDist + v) < nodes[k]['Distance'] then
					nodes[k]['Distance'] = curDist + v
					nodes[k]['Previous'] = currentNode
				end
			end
		end
	end
	
	while #unvisitedNodes > 0 do
		currentNode = _chooseNextMinimalDistance()
		_updateConnectedDistances()

		local foundAt = table.find(unvisitedNodes, currentNode)
		table.remove(unvisitedNodes, foundAt)
		table.insert(visitedNodes, currentNode)
	end
	
	local finished = false
	
	-- Target node.
	local current = 'C' 

	while finished == false do
		if current then
			local nextUp = nodes[current]['Previous']

			if nextUp then
				local communitativeA = current .. nextUp
				local communitativeB = nextUp .. current

				local beamFound: Beam = beamsFolder:FindFirstChild(communitativeA) or beamsFolder:FindFirstChild(communitativeB)
				beamFound.Color = ColorSequence.new(Color3.fromRGB(4, 255, 0))
			end

			current = nextUp
		else
			finished = true
		end

		task.wait(.05) -- Animation.
	end
end

for x = 1, 1000 do
	for _, beam in ipairs(beamsFolder:GetChildren()) do
		beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	end

	task.wait(.1) -- Animation.
	mainLoop()
end
