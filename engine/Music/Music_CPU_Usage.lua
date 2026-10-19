-- ================================================================
-- NES Music Engine CPU Usage Profiler with Histogram (Mesen Lua)
-- Tracks CPU cycles between writes to $00EF
-- Displays max, avg, percentiles, and scanline histogram
-- ================================================================

local FRAME_LOG_SIZE = 1000 
local FLAG_ADDR = 0x00EF
local SCANLINE_CYCLE = 113.666  -- NES cycles per scanline

local measuring = false
local startCycle = 0
local frameCycles = 0
local totalFrames = 0
local cycleLog = {}
local maxCycleEver = 0

-- === Histogram settings ===
local histogramBuckets = {
    "<10", "11", "12", "13", "14", "15-16",
    "17-18", "19-20", "21-25", "26-30", "31-35", "36-40",
    "41-50", ">50"
}
local histogramCounts = {}
for i = 1, #histogramBuckets do histogramCounts[i] = 0 end

-- === Helper: Read master clock ===
local function getCycleCount()
    return emu.getState().masterClock or 0
end

-- === Helper: Compute Statistics ===
local function calcStats()
    if #cycleLog == 0 then return nil end

    -- copy instead of mutating original
    local sorted = {}
    for i, v in ipairs(cycleLog) do
        sorted[i] = v
    end

    table.sort(sorted, function(a, b) return a > b end)
    local n = #sorted

    local max1000 = sorted[1]
    local sum = 0
    for _, v in ipairs(sorted) do sum = sum + v end
    local avgAll = sum / n

    local function avgTopPercent(p)
        local count = math.max(1, math.floor(n * p))
        local sumP = 0
        for i = 1, count do sumP = sumP + sorted[i] end
        return sumP / count
    end

    return {
        max1000 = max1000,
        avgAll  = avgAll,
        avg10   = avgTopPercent(0.10),
        avg1    = avgTopPercent(0.01),
        avg01   = avgTopPercent(0.001),
    }
end

		local function OLDcalcStats()
		    if #cycleLog == 0 then return nil end
		
		    table.sort(cycleLog, function(a, b) return a > b end)
		    local n = #cycleLog
		
		    local max1000 = cycleLog[1]
		    local sum = 0
		    for _, v in ipairs(cycleLog) do sum = sum + v end
		    local avgAll = sum / n
		
		    local function avgTopPercent(p)
		        local count = math.max(1, math.floor(n * p))
		        local sumP = 0
		        for i = 1, count do sumP = sumP + cycleLog[i] end
		        return sumP / count
		    end
		
		    return {
		        max1000 = max1000,
		        avgAll  = avgAll,
		        avg10   = avgTopPercent(0.10),
		        avg1    = avgTopPercent(0.01),
		        avg01   = avgTopPercent(0.001),
		    }
		end

-- === Callback: When $00EF is written ===
-- store previous 51-60 bucket value
local prevBucket_51_60 = 0
local prevFrameCycles = 0
local prevHistogram = {}

local function onFlagWrite(addr, value)
    if value == 1 and not measuring then
        measuring = true
        startCycle = getCycleCount()
    elseif value == 0 and measuring then
        local diff = getCycleCount() - startCycle
        measuring = false
        startCycle = 0
        frameCycles = diff

        -- Calculate scanlines
        local scanlines = math.floor(frameCycles / SCANLINE_CYCLE + 0.5)


        -- update histogram
        if scanlines <= 10 then
            histogramCounts[1] = histogramCounts[1] + 1
        elseif scanlines == 11 then
            histogramCounts[2] = histogramCounts[2] + 1
        elseif scanlines == 12 then
            histogramCounts[3] = histogramCounts[3] + 1
        elseif scanlines == 13 then
            histogramCounts[4] = histogramCounts[4] + 1
        elseif scanlines == 14 then
            histogramCounts[5] = histogramCounts[5] + 1
        elseif scanlines == 15 or scanlines == 16 then
            histogramCounts[6] = histogramCounts[6] + 1
        elseif scanlines == 17 or scanlines == 18 then
            histogramCounts[7] = histogramCounts[7] + 1
        elseif scanlines == 19 or scanlines == 20 then
            histogramCounts[8] = histogramCounts[8] + 1
        elseif scanlines >= 21 and scanlines <= 25 then
            histogramCounts[9] = histogramCounts[9] + 1
        elseif scanlines >= 26 and scanlines <= 30 then
            histogramCounts[10] = histogramCounts[10] + 1
        elseif scanlines >= 31 and scanlines <= 35 then
            histogramCounts[11] = histogramCounts[11] + 1
        elseif scanlines >= 36 and scanlines <= 40 then
            histogramCounts[12] = histogramCounts[12] + 1
        elseif scanlines >= 41 and scanlines <= 50 then
            histogramCounts[13] = histogramCounts[13] + 1
        else
            -- everything >50
            -- emu.displayMessage("Profiler", "Glitch? " .. frameCycles .. " cycles = " .. (frameCycles / SCANLINE_CYCLE))
            histogramCounts[14] = histogramCounts[14] + 1
        end


        -- insert into cycle log
        if #cycleLog >= FRAME_LOG_SIZE then table.remove(cycleLog, 1) end
        table.insert(cycleLog, frameCycles)
        if frameCycles > maxCycleEver then maxCycleEver = frameCycles end

        -- reset frameCycles for next measurement
        frameCycles = 0
    end
end


-- === Callback: Draw every frame ===
local function onFrame()
    totalFrames = totalFrames + 1
    local stats = calcStats()
    if not stats then return end

    local x, y = 10, 10
    local lineHeight = 10
    local bgColor = 0x88888888     -- opaque black
    local fgColor = 0x00000000     -- white text
    local shadowColor = 0x80000000  -- semi-transparent black shadow

    -- Draw background rectangle
    local rectHeight = 10 * (10 + #histogramBuckets)
    emu.drawRectangle(x - 2, y - 2, 300, rectHeight, bgColor, true, 1)

    -- Function to draw a line of text
    local line = function(txt)
        emu.drawString(x, y, txt, fgColor, shadowColor)
        y = y + lineHeight
    end

    -- Stats

	
	line(string.format("Frames: %d", totalFrames))
local labelX = x
local valueX = x + 90  -- tweak this until it looks right

local function lineKV(label, value)
    emu.drawString(labelX, y, label, fgColor, shadowColor)
    emu.drawString(valueX, y, value, fgColor, shadowColor)
    y = y + lineHeight
end

lineKV(string.format("Avg (Last %d):", FRAME_LOG_SIZE), string.format("%.1f", stats.avgAll))
lineKV("Avg Worst 10%:", string.format("%.1f", stats.avg10))
lineKV("Avg Worst 1%:", string.format("%.1f", stats.avg1))
lineKV(string.format("Max (Last %d):", FRAME_LOG_SIZE), string.format("%d", stats.max1000))
lineKV("Max Ever:", string.format("%d", maxCycleEver))

    -- Histogram
    line("")
    line("Scanline Histogram:")
    for i, bucket in ipairs(histogramBuckets) do
        line(string.format("%6s: %d", bucket, histogramCounts[i]))
    end
end

-- === Register Callbacks ===
emu.addMemoryCallback(onFlagWrite, emu.callbackType.write, FLAG_ADDR)
emu.addEventCallback(onFrame, emu.eventType.endFrame)

emu.displayMessage("CPU Profiler", "Initialized — watching $" .. string.format("%04X", FLAG_ADDR))
