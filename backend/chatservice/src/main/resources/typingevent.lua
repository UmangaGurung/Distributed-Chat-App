local key= KEYS[1]
local ttl= tonumber(ARGV[1])

if redis.call("EXISTS", key) == 1 then
	redis.call("EXPIRE", key, ttl)
	return "ALREADY_TYPING"
else
	redis.call("SET", key, 1, "EX", ttl)
	return "STARTED_TYPING"
end