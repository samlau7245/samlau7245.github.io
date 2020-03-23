# !/usr/local/bin/ruby -w

puts `git status`
puts `git add .`
print "Input Commit Log:"
log = gets
puts `git commit -m "#{log}"`
