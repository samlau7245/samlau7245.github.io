# !/usr/local/bin/ruby -w

print "Input Commit Log:"
log = gets

puts `git pull`
if log.length >= 0
	puts `git add .`
	puts `git commit -m "#{log}"`
	puts `git push`
end