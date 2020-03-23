---
title: Ruby 学习笔记
layout: post
categories:
 - ruby
---

## 入门

### 运行

直接运行Ruby文件

```ruby
ruby test.rb
```

或在Unix系统下可以设置文件位可执行文件:

```sh
# 设置
chmod +x test.rb
# 执行
./test.rb
```



```ruby
# !/usr/local/bin/ruby -w
```
## 类、对象和变量

### 继承、构造函数

```ruby
class Song
	# 系统类的构造函数
	def initialize(name, artist, duration) # 方法名、局部变量：小写字母 OR 下划线
		@name = name          # @ 是实例变量，对象类的所有方法都可以访问
		@artist = artist      # @ 是实例变量，对象类的所有方法都可以访问
		@duration = duration  # @ 是实例变量，对象类的所有方法都可以访问
	end
	# 重写了系统类中的 to_s 方法
	def to_s
		# return "Song: #@name -- #@artist -- #@duration"
		#"Song: #@name -- #@artist -- #@duration"
		"Song: #{@name} -- #{@artist} -- #{@duration}"
	end
end

class KaraokeSong < Song #  KaraokeSong 继承父类 Song
	def initialize(name, artist, duration,lyrics)
		super(name, artist, duration) # super 调用带参数的父类方法
		@lyrics = lyrics
	end
	# 继承父类方法
	def to_s
		super + " -- #{@lyrics}" # super 调用不带参数的父类方法
	end
end
```

### 类方法、实例方法、常量
```ruby
class Song
	MAX_TIME = 300 # 常量：首字母大写就是常量

	def Song.class_method(arg) # 工具方法
		arg * MAX_TIME
	end
	def instance_method(arg) # 对象方法
		arg * MAX_TIME
	end
end

Song.class_method(10) # 3000

song = Song.new
song.instance_method(20) # 6000
```
多参数的方法：

```ruby
class MyClass
	def MyClass.open(*args)
		puts args.class # Array
	end
end

MyClass.open("A","B","C")
```

## 容器、Blocks和迭代器

### 数组(Array)

```ruby
# 定义
arr1 = %w{1 2.2 a b } # ["1", "2.2", "a", "b"]
arr2 = [1,2.2,"a","b"] # [1, 2.2, "a", "b"]
arr3 = Array.new

arr2.class # Array
arr2.length # 4
arr2[5] # nil	

# 数组迭代器
%w{1 2 3 4}.each { |i| puts i}
```

给`Array`写分类方法：

```ruby
class Array
	def find
		#....
	end
end
[1,2,3,4].find
```

### 散列表(Hash)

```ruby
hash = {'k1' => 'v1', 'k2' => 'v2','k3' => 'v3'}
hash.length # 3
hash['k1']  # v1
hash['k2'] = 'v22'
hash # {"k1"=>"v1", "k2"=>"v22", "k3"=>"v3"}
```

### Blocks

两种Blocks绑定方式:`{...}`、`do...end`，他们唯一的区别:`{...}`绑定优先级高于 `do...end`。

不带参数的Blocks

```ruby
def call_back
	puts "start method"
	yield
	yield
	puts "start method"
end

call_back { puts "In the Block"} # 不带有参数的Block
# start method
# In the Block
# In the Block
# start method
#  ==> 通过 yield 调用，Block在方法里被调用了2次。

# 也可以使用另外一种Block使用形式
call_back do
	puts "In the Block"
end
```

带参数的Blocks

```ruby
def call_back
	puts "start method"
	yield("A","B")
	yield("C","D")
	puts "start method"
end
call_back { |arg1,arg2| puts arg1 + arg2} # 带有参数的Block

# start method
# AB
# CD
# start method

call_back  do |arg1,arg2|
	puts arg1 + arg2
end
```

带返回值Block


```ruby
class MyClass
	def method_name1
		return "A" if yield(4)
		return "B"
	end
end

a = MyClass.new
puts a.method_name1 { |arg| arg > 2} # A
puts a.method_name1 { |arg| arg > 6} # B
```

#### 作为闭包的Block

```ruby
class Song
	def play
		puts "play"
	end
	def pause
		puts "pause"
	end
end

class Button
	def initialize(label,&action)
		puts label
		@action = action
	end
	def button_pressed
		@action.call(self)
	end
end

song = Song.new
start_button = Button.new("A") {song.play}
pause_button = Button.new("B") {song.pause}

start_button.button_pressed # 可以执行 Proc#call 方法去调用相应的block
pause_button.button_pressed # 可以执行 Proc#call 方法去调用相应的block

# A
# B
# play
# pause
```

> 如果定义方法时，在最后一个参数前加`&`，那么在调用该方法时，Ruby会寻找一个Block。block将为转化成`Proc`类的一个对象，并赋值给参数。

## 标准类型(Standard Types)

`数字(Number)`、`字符串(String)`、`区间(Range)`、`正则表达式`

### 字符串(String)

* `%Q`分界符：可以看成双引号`"`的字符串，开始于`[`、`{`、`(`、`<`再读取到相匹配的结束符，在这个字符串里可以嵌入`#{...}`公式。
* `%q`分界符：可以看成单引号`'`的字符串，开始于`[`、`{`、`(`、`<`再读取到相匹配的结束符。
* `here document`

```ruby
%q-This is a doc!-
%Q-This is a doc!-

string = <<END_OF_STRING
Hello World!
Hello World!
Hello World!
END_OF_STRING

string = <<-END_OF_STRING
Hello World!
Hello World!
Hello World!
END_OF_STRING
```

### 区间

#### 区间作为序列(Ranges as Sequences)
* `..`：创建闭合的区间(包括右边的值),`[a,b]`。
* `...`：创建版闭半开的区间(不包括右边的值),`[a,b)`。

```ruby
(1..10).each { |i| print i," "} # 1 2 3 4 5 6 7 8 9 10
(1...10).each { |i| print i," "} # 1 2 3 4 5 6 7 8 9
('A'..'C').each { |i| print i," "} # A B C

a = (1...10).to_a # [1, 2, 3, 4, 5, 6, 7, 8, 9]
puts a.class # Array

ran = 0..9
puts ran.class # Range
puts ran.min # 0
puts ran.max # 9
puts ran.include?(5) # true
ran.each { |i| print i," "} # 0 1 2 3 4 5 6 7 8 9

t = ran.reject { |i| i < 5} # [5, 6, 7, 8, 9]
puts t.class # Array
```

Ruby可以为自定义的对象来创建区间：

```ruby
class MyClass
	attr :arg
	def initialize(arg)
		@arg = arg	
	end
	def <=>(other) # <=> : 也被称为太空船操作符
		self.arg <=> other.arg
	end
	def succ # 需要实现succ
		MyClass.new(@arg.succ) # 返回一个对象作为succ的响应
	end
end

cls = MyClass.new(4)..MyClass.new(5)
print cls.to_a # [#<MyClass:0x007fd1e7169048 @arg=4>, #<MyClass:0x007fd1e7168f08 @arg=5>
```

<!-- #### 区间作为条件(Ranges as Conditions) -->

#### 区间作为间隔(Ranges as Intervals)

```ruby
puts (1...10) === 5  # true
puts (1...10) === 15 # false
```

<!-- ### 正则(Regular Expressions) -->

## 方法

* 表示查询的方法通常以`?`结尾。
* `危险的`或者会修改接收者对象的方法，通常以`!`结尾。
* 定义一个以`=`结尾的方法名，便可使其能够出现在赋值操作的左边。

> `String`提供了两个方法`chop`、`chop!`，`chop` 返回一个修改后的字符串；`chop!`直接修改对象。

```ruby
# = 结尾的方法
class Song
	def arg=(new_arg)
		@arg = new_arg
	end
	def initialize(arg)
		@arg = arg
	end
end

song = Song.new("A")
song.arg = "B"
```

```ruby
# 无参数
def method_no_params
end
# 有参数
def method_with_params(arg1,arg2)
end
# 有参数，参数有默认值
def method_with_default_params(arg1="A",arg2="B")
	puts "--#{arg1}--#{arg2}--"
end
method_with_default_params # --A--B--
method_with_default_params("AA") # --AA--B--
```

可变长度的参数列表:

```ruby
def method_more_params(arg1,*arg2)
	"Got #{arg1} and #{arg2.join(', ')}"
end
method_more_params("A","B","C","D") # Got A and B, C, D

def method_name(arg1,arg2,arg3,arg4,arg5)
	"-#{arg1}-#{arg2}-#{arg3}-#{arg4}-#{arg5}-"
end
puts method_name(*(1..5).to_a)

def method_name2(*args)
	args.each { |i| print i}
end
method_name2(*(1..5).to_a)
```

### 方法和Block

```ruby
def take_block(arg)
	if block_given? # 判断是否实现Block
		yield(arg)
	else
		arg
	end
end

take_block("A") # A - 没实现block
take_block("A") { |i| puts i + "B"} # AB -实现block
```
如果方法定义的最后一个参数前缀为`&`，那么所关联的block会被转换为一个Proc对象。然后赋值给这个参数：

```ruby
class MyClass
	def initialize(arg1,&block)
		@arg1, @block = arg1, block
	end
	def method_test(arg)
	 	puts "#@arg1 on #{arg} = #{@block.call(arg) }"
	end
end

cls = MyClass.new("A") { |i| i + "BBBBB"}
cls.method_test("C") # A on C = CBBBBB
```

### 调用方法(Calling a Method)

```ruby
# !/usr/local/bin/ruby -w
self.class # Object
```

### 方法的范围值

每个方法都会返回一个值。**方法的返回值是执行的最后一个表达式的值，或者return表达式显式返回的值！**

多参数返回：

```ruby
def method_name
	return "A", "B", "C" # return 多个参数
end

var1, var2, var3 = method_name
print var1 + " " + var2 + " " + var3 + " " # A B C
```

方法参数为哈希数据：

```ruby
def method_name(arg1,arg2)
	puts arg2
end
method_name("A",{'k1' => 'v1','k2' => 'v2','k3' => 'v3'}) # {"k1"=>"v1", "k2"=>"v2", "k3"=>"v3"}
method_name("B",:k1 => :v1,:k2 => :v2,:k3 => :v3) # {:k1=>:v1, :k2=>:v2, :k3=>:v3}

# 另外一种写法：把方法的括号省略。
method_name 'B', :k1 => :v1, :k2 => 'C' # {:k1=>:v1, :k2=>"C"}
```

## 表达式(Expressions)

### 命令展开(Command Expansion)

使用反引号(\`)或者`%x`为前缀的分界形式，括起一个字符串，默认情况下会把它当成底层操作系统的命令来执行。

```ruby
puts `date` # 2020年 3月23日 星期一 15时59分06秒 CST
puts `ls` # 遍历当前目录
puts %x{echo "Hello World"}

# 重新定义反引号：
alias old_backquote `
def `(cmd)
	result = old_backquote(cmd)
	if $? != 0
		fail "AA"
	end
	result
end
```

### 并行赋值

```ruby
x = 0
a, b, c = x, (x += 1), (x += 1)
puts a,b,c # 0,1,2

a = [1,2,3,4]
b, c = a
print a,b,c # [1, 2, 3, 4] 1 2
b, *c = a
print b,c # 1 [2, 3, 4]
b, *c = 99, a
print b,c # 99 [[1, 2, 3, 4]]
b, *c = 99, *a
print b,c # 99 [1, 2, 3, 4]
```

### 条件执行(Conditional Execution)

* `defined?`：如果参数(可以是任意表达式)未被定义，返回`nil`；否则返回对参数的一个描述。如果参数是`yield`，而且有一个`block`和当前上下文相关联，那么返回字符串`yield`。
* `==`、`!=`、`>=`、`<=`、`>`、`<`：
* `===`：
* `<=>`：
* `=~`、`!~`：正则表达式匹配模式操作符。
* `eql?`：同类型+相等的值，true
* `equal?`：两对象的ID相同，true

```ruby
puts (1...10) === 5  # true
puts (1...10) === 15 # false
```

#### If和Unless表达式

* 处理语句和条件语句在一行可以使用`then`，或者把`then`代替为`:`，多行可以省略`then`。

```ruby
v1, v2 = true, false
if v1 == v2 then
	puts "A"
elsif v1 >= v2 then
	puts "B"
else
	puts "C"
end

if v1 == v2 then puts "A"
elsif v1 >= v2 then puts "B"
else puts "C"
end

if v1 == v2 : puts "A"
elsif v1 >= v2 : puts "B"
else puts "C"
end

if v1 == v2 
	puts "A"
elsif v1 >= v2 
	puts "B"
else
	puts "C"
end

v3 = v1 == v2 ? "A" : "B"
```

#### Case 表达式

* case可以测试独享到底是属于哪个类

```ruby
line = gets
var = case line 
when "1" then "A"
when "2","3" then "B"
else "C"
end

var = case line 
when "1" : "A"
when "2","3" : "B"
else "C"
end

var = case line 
when "1" 
	"A"
when "2","3"
	"B"
else 
	"C"
end

case condition
when Array
when String
else	
end
```

#### 循环(Loop)
s
sss


















































































