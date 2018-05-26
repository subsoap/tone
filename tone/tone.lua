local M = {}

M.sound_list = {}
M.gated_time = 0.3 -- prevent the same sound from playing within this time
M.master_gain = 1
M.verbose = false

function M.toggle_verbose()
	if M.verbose == false then
		M.verbose = true
	else
		M.verbose = false
	end
end

function M.add_sound(name, url, delay, gain)
	assert(M.sound_list[name] == nil, "Tone: tone.add_sound - The sound " .. name .. " already exists.")
	assert(url ~= nil, "Tone: A url must be set when adding a sound.")
	if M.verbose then print("Tone: tone.add_sound - added " .. name .. " to sound list.") end
	M.sound_list[name] = {}
	M.sound_list[name].url = url
	M.sound_list[name].delay = delay or 0
	M.sound_list[name].gain = gain or 1
	M.sound_list[name].gated = gated or false
	M.sound_list[name].gated_timer = 0
end

function M.play_sound(name, delay, gain, gated)
	assert(M.sound_list[name] ~= nil, "Tone: tone.play_sound - The sound " .. name .. " doesn't exist.")
	if M.verbose then print("Tone: tone.play_sound - playing " .. name .. ".") end
	local tone = M.sound_list[name]
	gated = gated or tone.gated
	if gated then
		if tone.gated_timer ~=0 then
			return false
		end
		M.sound_list[name].gated_timer = M.gated_time
	end
	gain = gain or tone.gain
	msg.post(tone.url, "play_sound", {delay = delay or tone.delay, gain = gain * M .master_gain})
	return true
end

function M.stop_sound(name)
	assert(M.sound_list[name] ~= nil, "Tone: tone.stop_sound - The sound " .. name .. " doesn't exist.")
	if M.verbose then print("Tone: tone.stop_sound - stopping " .. name .. ".") end
	local tone = M.sound_list[name]
	msg.post(tone.url, "stop_sound")
end

function M.update(dt)
	for name,_ in pairs(M.sound_list) do
		M.sound_list[name].gated_timer = M.sound_list[name].gated_timer - dt
		if M.sound_list[name].gated_timer < 0 then
			M.sound_list[name].gated_timer = 0
		end
	end
end

return M