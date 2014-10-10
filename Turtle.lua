COBBLE_SLOT = 2
CURRENT_SLOT = COBBLE_SLOT
LAST_SLOT = COBBLE_SLOT
SAND_SLOT = 5
GRAVEL_SLOT = 3
DIRT_SLOT = 4
STONE_SLOT = 1
TORCH_SLOT = 6
ENDER_CHEST_SLOT = 7
FUEL_SLOT = 16
MIN_FUEL_COUNT = 16
TORCH_SPACE = 10
DISTANCE = 0
currentSlot = 1
INV_COUNT = 7
WALL_DEPTH = 4
recursiveDepth = 4
repetition = 2
TORCH_COUNT = 0
FUEL_USED = 0
LAST_FUEL = 0
ORE = 0
TOTAL_BLOCKS = 0

 
function A(depth)  -- A and B is the Hilbert curve recursion loop
 
   if depth < 1 then return end
   turtle.turnLeft()
   B(depth - 1)
   MineForward(3)
   turtle.turnRight()
   A(depth - 1)
   MineForward(3)
   A(depth - 1)
   turtle.turnRight()
   MineForward(3)
   B(depth - 1)
   turtle.turnLeft()
 
end
 
function B(depth)
 
   if depth < 1 then return end
   turtle.turnRight()
   A(depth - 1)
   MineForward(3)
   turtle.turnLeft()
   B(depth - 1)
   MineForward(3)
   B(depth - 1)
   turtle.turnLeft()
   MineForward(3)
   A(depth - 1)
   turtle.turnRight()
 
end
 
function MineForward( thisFar )
	
	local i
	
	for i = 1, thisFar do  		--mine a 1x2 tunnel forward a given number of units
	if turtle.detect() then		--if there is a block in front of the turtle remove it
		RemoveBlock("forward")
	end
	turtle.forward()
	
	if turtle.detectDown() then
		if IsOre("down") then MineOre("down") end
	else
		FillLiquid("down")		--prevents water or lava from filling the tunnel
	end
	
	turtle.turnLeft()
	if turtle.detect() then
		if IsOre("forward") then MineOre("forward") end
	else
		FillLiquid("forward")
	end
	RemoveBlock("up")
	
	turtle.up()
	if turtle.detectUp() then
		if IsOre("up") then MineOre("up") end
	else
		FillLiquid("up")
	end
	
	if turtle.detect() then
		if IsOre("forward") then MineOre("forward") end
	else
		FillLiquid("forward")
	end
	turtle.turnRight()
	turtle.turnRight()
	
	if turtle.detect() then
		if IsOre("forward") then MineOre("forward") end
	else
		FillLiquid("forward")
	end
	turtle.down()
	
	TorchCheck()			--check to see if we need to place a torch
	FuelCheck()				--make sure we're not out of fuel
	
	if turtle.detect() then
		if IsOre("forward") then MineOre("forward") end
	else
		FillLiquid("forward")
	end
	turtle.turnLeft()
	
	Stats("distance")		--add one to distance travelled and display stats
	
	if IsFull() then CheckInventory() end	--dump inventory if it's full
	end
end
 
function BlockHandler( here )				--not sure if I really need to use this anymore, used to do more
	if IsOre(here) then	MineOre(here) end 	--may just inline it
end

function CheckInventory( onInit )
	print("Checking inventory...")	
	local n = 0
	
	for i = INV_COUNT+1, 15 do				--first consolidate fuel items into one slot
		Select(FUEL_SLOT)
		if turtle.compareTo(i) then
			turtle.select(i)
			CURRENT_SLOT = i
			turtle.transferTo(FUEL_SLOT)	
		end
		Select(LAST_SLOT)
	end
	
	for i = 1, 14 do
		if turtle.getItemCount(i) > 0 then		--slot used, reorganize, checking for duplicate slots
			n = n + 1
			CheckSlotDupes(i)
		end	
	end
	
	result = n
	
	if n > 13 then 								--if inventory is full dump it into a chest
		result = DumpInventory("forward") 
	end
	print("Done")
	return result
end	

function CheckSlotDupes ( index )	--check inventory slots for duplicate items, condense
	local i
	local begin	
	if index < INV_COUNT+1 then begin = INV_COUNT+1 
	else begin = index + 1 end
	Select(index)
	for i = begin, 15 do
		if turtle.compareTo(i) then
			turtle.select(i)
			CURRENT_SLOT = i
			turtle.transferTo(index)
		end 
	end 
	Select(LAST_SLOT)
end
	
function Compare( here )	--compare selected slot to block
	if here == "up" then return turtle.compareUp()
	elseif here == "down" then return turtle.compareDown()
	elseif here == "forward" then return turtle.compare() end return false end
 
function Detect ( here )	--detect if block is air/water/lava or mineable
	if here == "up" then return turtle.detectUp()
	elseif here == "down" then return turtle.detectDown()
	elseif here == "forward" then return turtle.detect() end return false end
 
function DumpInventory( here ) --drops chest and fills it
	local i, g, result
	result = -1
	print("Placing chest...")
	if Detect("forward") then
		RemoveBlock("forward")
	end											--place chest
	Select(ENDER_CHEST_SLOT)
	turtle.place()
	for i = INV_COUNT+1, 15 do
		print(i)
		turtle.select(i)
		CURRENT_SLOT = i
		turtle.drop()
		sleep(.1)
	end
	Select(LAST_SLOT)
	FuelCheck()
	g = turtle.getItemCount(FUEL_SLOT)		--dump fuel items if we have too many
	if g > MIN_FUEL_COUNT then
		Select(FUEL_SLOT)
		turtle.drop(g - MIN_FUEL_COUNT)
	end
	Select(LAST_SLOT)
	RemoveBlock("forward")		--destroy chest
	turtle.forward()  			--check to see if there is anything here to mine
	BlockHandler("forward")
	BlockHandler("up")
	BlockHandler("down")
	Right(BlockHandler, "forward")
	Left(BlockHandler, "forward")
	turtle.back()
	return result
end 

function Dig( here )
	TOTAL_BLOCKS = TOTAL_BLOCKS + 1  --stats
	if here == "up" then return turtle.digUp()
	elseif here == "down" then return turtle.digDown()
	elseif here == "forward" then return turtle.dig() end end

function FillLiquid( here )		--places a block
	Select(COBBLE_SLOT)
	if here == "all" then
		Place("forward")
		Place("up")
		Place("down")
		Left(Place, "forward")
		Right(Place, "forward")	
	else 
		Place(here) 
	end
	Select(LAST_SLOT)
end

function FuelCheck()		--checks fuel level
	local GC = turtle.getItemCount
	print("Fuel: " .. turtle.getFuelLevel())
	Stats("fuel")
	if turtle.getFuelLevel() < 100 then
		Select(FUEL_SLOT)
		print("Refueling " .. (GC(FUEL_SLOT) - 1) .. " units")
		return turtle.refuel(GC(FUEL_SLOT) - 1) 
	end 
	Select(LAST_SLOT)
end
	
	
function InitFuel()  --used on first run
	print("Checking fuel")
	LAST_FUEL = turtle.getFuelLevel()
	return FuelCheck() end
	
function IsFull ( )		--checks to see if inventory is full
	local n, i
	for i = INV_COUNT+1, 15 do
		if turtle.getItemCount(i) > 0 then
		else 
			return false 
		end 
	end 
	return true 
end	
	
function IsOre(here)		--cycles through inventory slots and compares to a block
							--if it doesn't match our "junk" inventory, it's an ore
	local i

	if Compare(here) then
		if CURRENT_SLOT > INV_COUNT then
			result = true
		else
			result = false
		end
	else
		for i = 1, 15 do
			turtle.select(i)
			CURRENT_SLOT = i
			if Compare(here) then
				if i > INV_COUNT then 
					result = true
					break
				else
					result = false
					break
				end
			end
		end
	end

	print(result)
	
	if result == nil then result = true end
	return result
end

function Left( doThis, here )  --turn left, call a function, turn right	
	local result
	local doIt = doThis	
	turtle.turnLeft()
	result = doIt(here)
	turtle.turnRight()
	return result
end

function MineOre( here )					--remove surrounding vein	
	local m = MineOre						--declaring functions locally is supposed to be 
	local a = 0								--much faster in lua
	local RB = RemoveBlock
	local M = Move
	local R = Right
	local BH = BlockHandler
	local RH = RotateH
	local TS = Select
	local TB = turtle.back
	local P = Place
	local D = turtle.down
	local U = turtle.up
	
	RB(here)						--get ore and move in	
	M(here)
	if here == "forward" then				--send surrounding area to the BlockHandler
		R(BH, "forward")
		BH("up")
		Left(BH, "forward")
		BH("down")
		BH("forward")	
	else 
		RH(BH, "forward")
		BH(here)
	end	
	TS(COBBLE_SLOT)
	if here == "forward" then				--covering up our tracks
		TB()
		P(here)
	elseif here == "up" then
		D()
		P(here)
	elseif here == "down" then
		U()
		P(here)
	end
	TS(LAST_SLOT)
end
 
function Move ( here )
	if here == "up" then return turtle.up()
	elseif here == "forward" then
		return turtle.forward()
	elseif here == "down" then return turtle.down()
	elseif here == "back" then return turtle.back()
	else return nil 
	end 
	
end
 
function Place( here )		--places block up, forward or down.  fills in with gravel below
		if here == "up" then 
			return turtle.placeUp()
		elseif here == "down" then 
			turtle.placeDown()
			if not turtle.detectDown() then  --if there is a gap under the turtle, drop gravel to fill in
				Select(GRAVEL_SLOT)
				--turtle.placeDown()
				return Place("down")
				--Select(LAST_SLOT)
			else turtle.placeDown() 
			end
		elseif here == "forward" then 
			return turtle.place() 
		end 
	return false 
end
 
function RemoveBlock( here )  --removes block and any gravel/sand (sand/gravel from above falls down when mined)
	local failsafe = 0	
	
		if here == "down" then Dig("down")
		else 
			if Dig(here) == true then
				Select(GRAVEL_SLOT)
				if Compare(here) == true then
					failsafe = 0
					while Dig(here) and (failsafe < 16) do  --infinite loop protection
					sleep(.5)
					failsafe = failsafe + 1 
				end
				Select(LAST_SLOT)
			end
		end 
	end 
end

function Right ( doThis, here )  --turn right, call a function, turn left
	 local result
	 local doIt = doThis	
	 turtle.turnRight()
	 result = doIt(here)
	 turtle.turnLeft()
	 return result end 

function RotateH( doThis, here ) --rotates and calls a function
	local result
	local doIt = doThis	
	turtle.turnRight()
	doIt(here)
	turtle.turnRight()
	doIt(here)
	turtle.turnRight()
	doIt(here)
	turtle.turnRight()
	doIt(here) end 

function Stats ( this, that )		--prints various stats
	FUEL_USED = FUEL_USED + LAST_FUEL - turtle.getFuelLevel()
	LAST_FUEL = turtle.getFuelLevel()
	if this == "distance" then
		DISTANCE = DISTANCE + 1
		if DISTANCE % 5 == 0 then	
			print(DISTANCE .. "m tunneled.")
			print(((TOTAL_BLOCKS + ORE) / DISTANCE) .. " blocks mined per tunnel section.")
			print((FUEL_USED/(TOTAL_BLOCKS + ORE)).. " fuel per block.")return true
		end
	elseif this == "torch" then TORCH_COUNT = TORCH_COUNT + 1
		return true
	elseif this == "fuel" then FUEL_USED = FUEL_USED + (LAST_FUEL - turtle.getFuelLevel())
		print(FUEL_USED .. " total fuel used.")
		print((FUEL_USED / DISTANCE) .. " fuel per m.")
		print((FUEL_USED / ORE) .. " fuel per extra ore.")
		print((turtle.getFuelLevel() /(FUEL_USED/DISTANCE)) .. "m's of fuel left.")
		return true
	elseif this == "ore" then ORE = ORE + 1
		print(ORE .. " extra ore mined.") 
		print((FUEL_USED / ORE) .. " per ore.") return true
	elseif this == "fuelchunks" then end return false end	

function Select ( slot )
	LAST_SLOT = CURRENT_SLOT
	turtle.select(slot)
	CURRENT_SLOT = slot
end
	
function TorchCheck()	--checks to see if torch needs to be placed
	local BH = BlockHandler
	if (DISTANCE % TORCH_SPACE) == 0 and turtle.getItemCount(TORCH_SLOT) > 0 then
		Stats("torch")	
		RemoveBlock("forward")
		turtle.forward()
		
		if turtle.detect() then
			BH("forward")
		else
			FillLiquid("forward")
		end
		
		if turtle.detectDown() then
			BH("down")
		else
			FillLiquid("down")
		end
		
		turtle.back()
		Select(TORCH_SLOT)
		Place("forward")
		Select(LAST_SLOT)
	end 
end 

function main()  --main deal
	
	InitFuel()
	local AA = A
	for i=1, repetition do
	AA(2) end

	
end

main()
