---
title: Ruby 学习笔记
layout: post
categories:
 - ruby
---


### 数组(Array)

```ruby
arr1 = %w{1 2.2 a b } # ["1", "2.2", "a", "b"]
arr2 = [1,2.2,"a","b"] # [1, 2.2, "a", "b"]
arr3 = Array.new

arr2.class # Array
arr2.length # 4
arr2[5] # nil
```

### 散列表(Hash)

```ruby
hash = {'k1' => 'v1', 'k2' => 'v2','k3' => 'v3'}
hash.length # 3
hash['k1']  # v1
hash['k2'] = 'v22'
hash # {"k1"=>"v1", "k2"=>"v22", "k3"=>"v3"}
```