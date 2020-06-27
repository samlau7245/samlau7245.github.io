---
title: GitBook 博客搭建
layout: post
categories:
 - diary
---

```sh
# 搭建环境
sudo npm install gitbook-cli
```

> 所有的操作都在`GitBook`目录中完成。我们需要创建一个名为`objc-book`的书籍。

## 创建电子书的章节目录

```sh
% mkdir objc-book
% cd objc-book 
% gitbook init
# warn: no summary file in this book 
# info: create README.md 
# info: create SUMMARY.md 
# info: initialization is finished 
```

> `gitbook init` 在`node 14.0.0`环境中报错，用低版本的`node`。

现在的树结构：

```
.
└── objc-book
    ├── README.md
    └── SUMMARY.md
```

* `README.md` : 默认首页文件,相当于网站的首页`index.html`,一般是介绍文字或相关导航链接。
* `SUMMARY.md` : 是默认概括文件,主要是根据该文件内容生成相应的目录结构。

```
# Summary

## Part I

* [Introduction](README.md)
* [BASIC](basic.md)
	* [BASIC-2](basic.md)
		* [BASIC-BASIC-2BASIC-22](basic.md)
		

## Part I

* [Introduction](README.md)
* [BASIC](basic.md)
	* [BASIC-2](basic.md)

----

* [Introduction](README.md)
```

<img src="/assets/images/GitBook/02.png"/>

## 运行电子书

```sh
shanliu@shanliudeMac-mini GitBook % git serve ./objc-book/
git: 'serve' is not a git command. See 'git --help'.

The most similar command is
	merge
shanliu@shanliudeMac-mini GitBook % gitbook serve ./objc-book/
Live reload server started on port: 35729
Press CTRL+C to quit ...

info: 7 plugins are installed 
info: loading plugin "livereload"... OK 
info: loading plugin "highlight"... OK 
info: loading plugin "search"... OK 
info: loading plugin "lunr"... OK 
info: loading plugin "sharing"... OK 
info: loading plugin "fontsettings"... OK 
info: loading plugin "theme-default"... OK 
info: found 1 pages 
info: found 0 asset files 
info: >> generation finished with success in 0.4s ! 

Starting server ...
Serving book on http://localhost:4000
```

<img src="/assets/images/GitBook/01.png"/>

或者直接`cd`到`objc-book`根目录下运行。

```sh
shanliu@shanliudeMac-mini GitBook % cd objc-book 
shanliu@shanliudeMac-mini objc-book % gitbook serve
Live reload server started on port: 35729
Press CTRL+C to quit ...

info: 7 plugins are installed 
info: loading plugin "livereload"... OK 
info: loading plugin "highlight"... OK 
info: loading plugin "search"... OK 
info: loading plugin "lunr"... OK 
info: loading plugin "sharing"... OK 
info: loading plugin "fontsettings"... OK 
info: loading plugin "theme-default"... OK 
info: found 1 pages 
info: found 0 asset files 
info: >> generation finished with success in 0.4s ! 

Starting server ...
Serving book on http://localhost:4000
```

不过因为操作都是基于`GitBook`根目录，所以下面的操作都不会`cd`到具体的目录。

## 创建资源文件

```
.
├── README.md
├── SUMMARY.md
├── _posts => 这个文件夹存放文章
├── assets => 这个文件夹存放资源
│   ├── csv
│   │   └── test.csv
│   ├── images
│   │   └── favicon.ico
│   └── shell
│       └── test.sh
├── book.json => 这个文件是配置文件
└── website.css => 这个文件是配置文件
```

## 配置文件

`book.json`

```json
{
    "title":"书籍的标题",
    "author":"书籍的作者",
    "description":"书籍的简要描述.",
    "isbn":"书籍的国际标准书号",
    "links":{
        "sidebar":{
            "我的网站1":"https://snowdreams1006.cn/",
            "我的网站2":"https://snowdreams1006.cn/"
        },
        "styles":{
            "website":"styles/website.css",
            "ebook":"styles/ebook.css",
            "pdf":"styles/pdf.css",
            "mobi":"styles/mobi.css",
            "epub":"styles/epub.css"
        }
    },
    "plugins":[
        "simple-page-toc",
        "anchor-navigation-ex",
        "-lunr",
        "-search",
        "search-plus",
        "advanced-emoji",
        "splitter",
        "expandable-chapters-small",
        "local-video",
        "anchors",
        "copy-code-button",
        "alerts",
        "include-csv",
        "include-codeblock",
        "ace",
        "favicon",
        "todo"
    ],
    "pluginsConfig":{
        "simple-page-toc":{
            "maxDepth":3,
            "skipFirstH1":true
        },
        "anchor-navigation-ex":{
            "showLevel":true,
            "associatedWithSummary":true,
            "printLog":false,
            "multipleH1":true,
            "mode":"float",
            "showGoTop":true,
            "float":{
                "floatIcon":"fa fa-navicon",
                "showLevelIcon":false,
                "level1Icon":"fa fa-hand-o-right",
                "level2Icon":"fa fa-hand-o-right",
                "level3Icon":"fa fa-hand-o-right"
            },
            "pageTop":{
                "showLevelIcon":false,
                "level1Icon":"fa fa-hand-o-right",
                "level2Icon":"fa fa-hand-o-right",
                "level3Icon":"fa fa-hand-o-right"
            },
            "disqus":{
                "shortName":"gitbookuse"
            },
            "include-codeblock":{
                "template":"ace"
            },
            "favicon":{
                "shortcut":"assets/images/favicon.ico",
                "bookmark":"assets/images/favicon.ico",
                "appleTouch":"assets/images/favicon.ico",
                "appleTouchMore":{
                    "120x120":"assets/images/favicon.ico",
                    "180x180":"assets/images/favicon.ico"
                }
            }
        }
    }
}
```

安装依赖：`gitbook install`。

## 发布到GitPage

* 创建仓库`https://github.com/{userName}/objc-book.git`。

```
cd ./GitBook
git clone -b gh-pages https://github.com/{userName}/objc-book.git objc-book-gh-pages
```

* 创建分支

```sh
cd objc-book-master 
# 创建 gh-pages 分支，分支名必须是这个
git checkout -b gh-pages
# push到远程
git push --set-upstream origin gh-pages
```

这样就可以以`GitPage`的方式访问页面:`http://{userName}.github.io/objc-book/`

* 把分支拉取到本地

```sh
cd ./GitBook
git clone -b gh-pages https://github.com/{userName}/objc-book.git objc-book-gh-pages
```

现在整体的目录结构:

```
GitBook
├── objc-book
├── objc-book-gh-pages => 分支
└── objc-book-master => 主干，可以把 objc-book 代码放到主干中，作为日常草稿，等到需要发布到线上时，再 gitbook build 到 gh-pages 分支。
```

* 把`objc-book`目录中的内容移到`objc-book-master`，上传到仓库。

```sh
cd ./objc-book-master
git add .
git commit -m "add"
git push
```

* 发布到 gh-pages 分支

```sh
cd ./GitBook
gitbook build ./objc-book-master ./tmp
# 再把 tmp 文件夹中的内容拷贝到 objc-book-gh-pages ，上传到远程仓库。就发布成功了。
```

## .gitignore 文件

```
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Diagnostic reports (https://nodejs.org/api/report.html)
report.[0-9]*.[0-9]*.[0-9]*.[0-9]*.json

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Directory for instrumented libs generated by jscoverage/JSCover
lib-cov

# Coverage directory used by tools like istanbul
coverage
*.lcov

# nyc test coverage
.nyc_output

# Grunt intermediate storage (https://gruntjs.com/creating-plugins#storing-task-files)
.grunt

# Bower dependency directory (https://bower.io/)
bower_components

# node-waf configuration
.lock-wscript

# Compiled binary addons (https://nodejs.org/api/addons.html)
build/Release

# Dependency directories
node_modules/
jspm_packages/
_book/

# TypeScript v1 declaration files
typings/

# TypeScript cache
*.tsbuildinfo

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env
.env.test

# parcel-bundler cache (https://parceljs.org/)
.cache

# Next.js build output
.next

# Nuxt.js build / generate output
.nuxt
dist

# Gatsby files
.cache/
# Comment in the public line in if your project uses Gatsby and *not* Next.js
# https://nextjs.org/blog/next-9-1#public-directory-support
# public

# vuepress build output
.vuepress/dist

# Serverless directories
.serverless/

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

```

## 插件

### [anchor-navigation-ex](https://github.com/zq99299/gitbook-plugin-anchor-navigation-ex)浮动目录导航

```json
{
    "plugins":[
        "anchor-navigation-ex"
    ],
    "pluginsConfig":{
        "anchor-navigation-ex":{
            "showLevel":false,
            "associatedWithSummary":true,
            "printLog":true,
            "multipleH1":true,
            "mode":"float",
            "float":{
                "showLevelIcon":false,
                "level1Icon":"fa fa-hand-o-right",
                "level2Icon":"fa fa-hand-o-right",
                "level3Icon":"fa fa-hand-o-right"
            }
        }
    }
}
```

<img src="/assets/images/GitBook/03.png"/>


### [copy-code-button]()代码复制

```json
{
"plugins":["copy-code-button"]
}
```

### [simple-page-toc]()自动生成本页的目录结构

```json
{
    "plugins" : [
        "simple-page-toc"
    ],
    "pluginsConfig": {
        "simple-page-toc": {
            "maxDepth": 3,
            "skipFirstH1": true
        }
    }
}
```

使用：

在需要使用的地方添加`<!-- toc -->`

### [expandable-chapters-small]()左侧的章节目录可以折叠

```json
plugins: ["expandable-chapters-small"]
```

### [emphasize]()浮动目录导航

```json
{
    "plugins": [
        "emphasize"
    ]
}
```

<img src="/assets/images/GitBook/04.png"/>

### [search-plus]()支持中文搜索

```json
{
    "plugins": ["-lunr", "-search", "search-plus"]
}
```

## 资料

* [GitBook文档（中文版）](https://chrisniael.gitbooks.io/gitbook-documentation/editor/draft.html) 
* [GitBook 插件](http://gitbook.zhangjikai.com/plugins.html)

<!-- 

### []()浮动目录导航

```json

```

-->

<!-- <img src="/assets/images/GitBook/.png"/> -->

 




















