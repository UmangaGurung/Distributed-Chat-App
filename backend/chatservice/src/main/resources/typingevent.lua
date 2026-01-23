local key= KEYS[1]
local event= ARGV[1]

if event=="NOT_TYPING" then
	redis.call("DEL", key)
	return event
elseif event=="TYPING" then
	redis.call("SET", key, event)
	return event
end