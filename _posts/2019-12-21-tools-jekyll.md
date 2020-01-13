---
title: Jekyll 使用手册
layout: post
description: 搭建一个属于自己的博客系统。
categories:
 - tools
---

## 头信息

### 添加「标题」页面

```
---
title: Blogging Like a Hacker
layout: post
---
```

### 添加「标题链接」页面

```
---
title: Blogging Like a Hacker
link: http://www.google.com/
---
```

### 添加「描述」页面

```
---
description: this is a description
---
```

### 添加「日期」页面

```
---
title: Categories
date: 2013-12-24 23:30:09
---
```

### 添加「分类」页面

```
---
categories:
 - categorie_name1
 - categorie_name2
---
```

### 添加「标签」页面

```
---
tags:
 - tag_name1
 - tag_name2
---
```

---

### 添加「图片」页面

```
type: photo
title: Gallery Post
photos:
- http://ww1.sinaimg.cn/mw690/81b78497jw1emfgwkasznj21hc0u0qb7.jpg
- http://ww3.sinaimg.cn/mw690/81b78497jw1emfgwjrh2pj21hc0u01g3.jpg
- http://ww2.sinaimg.cn/mw690/81b78497jw1emfgwil5xkj21hc0u0tpm.jpg
- http://ww3.sinaimg.cn/mw690/81b78497jw1emfgvcdn25j21hc0u0qpa.jpg
---
```

---

## 创建文章

在`_posts` 文件夹中创建`年-月-日-标题.MARKUP`格式的文件。

```
2011-12-31-new-years-eve-is-awesome.md
2012-09-12-how-to-write-a-blog.textile
```

引用图片资源

```
![有帮助的截图](/assets/images/261576903527_.pic_hd.jpg)

![Desktop Preview](http://iissnan.com/nexus/next/desktop-preview.png)
```

## 内容元素

---

```
# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6
```

---

~~Deleted text~~

```
~~Deleted text~~
```

---

<dl><dt>Definition List Title</dt><dd>This is a definition list division.</dd></dl>

```
<dl><dt>Definition List Title</dt><dd>This is a definition list division.</dd></dl>
```

---

- List Item 1
- List Item 2
- List Item 3


```
- List Item 1
- List Item 2
- List Item 3
```

---

| Table Header 1 | Table Header 2 | Table Header 3 |
| --- | --- | --- |
| Division 1 | Division 2 | Division 3 |
| Division 1 | Division 2 | Division 3 |
| Division 1 | Division 2 | Division 3 |

```
| Table Header 1 | Table Header 2 | Table Header 3 |
| --- | --- | --- |
| Division 1 | Division 2 | Division 3 |
| Division 1 | Division 2 | Division 3 |
| Division 1 | Division 2 | Division 3 |
```

---

AAA <sup>AAA</sup> AAA <br/>
AAA <sub>AAA</sub> AAA <br/>
AAA<cite>AAA</cite>AAA <br/>
<acronym title="National Basketball Association">AAA</acronym> <br/>
<abbr title="Avenue">AAA</abbr>

```
AAA <sup>AAA</sup> AAA 
AAA <sub>AAA</sub> AAA 
AAA<cite>AAA</cite>AAA 
<acronym title="National Basketball Association">AAA</acronym> 
<abbr title="Avenue">AAA</abbr>
```

---

\\( \sqrt{\frac{n!}{k!(n-k)!}} \\)

```
\\( \sqrt{\frac{n!}{k!(n-k)!}} \\)
```

## 运行Jekyell

```sh
bundle exec jekyll server --draft
```

## 注册域名、关联`Github Page`


### 获取`Github Page`的IP

```sh
ping xxx.github.io

# 输出
PING xxx.github.io (14.215.177.39): 56 data bytes
```

### 购买域名(阿里云)

购买成功后到`域名控制台`中，选中你自己的域名`xxx.work`，执行`解析`； 把IP关联到域名。


## GitHub page

## 参考资料

- 
[NexT](http://theme-next.simpleyyt.com)
- 
[jekyllcn](http://jekyllcn.com)