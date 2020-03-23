# !/usr/local/bin/ruby -w

puts `git pull`
puts `git status`
puts `git add .`
print "Input Commit Log:"
log = gets
puts `git commit -m "#{log}"`
puts `git push`