#!/bin/bash

# 远程仓库地址
REPO_URL=(
	"https://github.com/samlau7245/database-book.git"
	"https://github.com/samlau7245/design-book.git"
	"https://github.com/samlau7245/devnote-book.git"
	"https://github.com/samlau7245/flutter-book.git"
	"https://github.com/samlau7245/objc-book.git"
	"https://github.com/samlau7245/spring-book.git"
	"https://github.com/samlau7245/swift-book.git"
	);

# 仓库分支
REPO_BRANCH=( "master" "gh-pages" );

#零时分支
TEMP_DIR_NAME="-tmp"

ROOT_DIR="GitBook";

GITEE_URL="https://gitee.com/BOOKREC/";
GITEE_DIR="gitee";

# 提取仓库文件夹文件夹:( database-book design-book devnote-book flutter-book objc-book spring-book swift-book )

REPO_URL_NAME=();
for url in ${REPO_URL[@]}; do
	git_full_name=${url##*/};
	git_name=${git_full_name%.*};
	REPO_URL_NAME[${#REPO_URL_NAME[@]}]="$git_name";
done

# GITEE 仓库地址
GITT_REPO_URL_NAME=();
for url in ${REPO_URL[@]}; do
	git_full_name=${url##*/};
	GITT_REPO_URL_NAME[${#GITT_REPO_URL_NAME[@]}]="$GITEE_URL$git_full_name";
done

checkEnv(){
	if [[ -e  $ROOT_DIR ]]; then
		cd $ROOT_DIR;
		return;
	else
		echo "请先初始化！";
		exit;
	fi
}

# ========== 目录结构搭建 ==========
# 判断是否创建根目录
creatRootDir(){
	if [[ -d $ROOT_DIR ]]; then
		echo "根目录已经初始化！";
		exit;
	else
	read -p "当前目录没有GitBook根目录，是否创建[y/n]? " is_create
		case $is_create in
			y ) 
			mkdir $ROOT_DIR;
				;;
			n|* ) exit;
				;;	
		esac	
	fi
}

# ========== 仓库操作 ==========
chooseOperationType(){
	read -p "选择仓库操作[clone:1,pull:2,push:3,del:4]? " value;
	return $value;
}

chooseBranch(){
	read -p "选择分支[master:0,gh-pages:1,所有分支:2]? " value;
	return $value;
}


# ==================================clone======================================

clone_branch(){
	for (( i = 0; i < ${#REPO_URL[@]}; i++ )); do
		repo_local_name=${REPO_URL_NAME[$i]}-$1;
		git clone -b $1 ${REPO_URL[$i]} ${REPO_URL_NAME[$i]}-$1;
	done
}	

operation_clone(){
	
	branch=$1;
	echo $branch;

	if [[ $branch == 2 ]]; then #全部分支
		for i in ${REPO_BRANCH[@]}; do
			clone_branch $i
		done
	fi

	if [[ $branch == 0 || $branch == 1 ]]; then #指定分支
		clone_branch ${REPO_BRANCH[$branch]}
	fi
}

# ==================================pull======================================

pull_branch(){
	for (( i = 0; i < ${#REPO_URL[@]}; i++ )); do
		repo_local_name=${REPO_URL_NAME[$i]}-$1;
		if [[ -d  $repo_local_name ]]; then
			cd $repo_local_name;
			git pull
			cd ..
		else
			echo "$repo_local_name 分支不存在！"
		fi
	done
}	

operation_pull(){
	
	branch=$1;
	echo $branch;

	if [[ $branch == 2 ]]; then #全部分支
		for i in ${REPO_BRANCH[@]}; do
			pull_branch $i
		done
		return;
	fi

	if [[ $branch == 0 || $branch == 1 ]]; then #指定分支
		pull_branch ${REPO_BRANCH[$branch]}
	fi
}	

# ==================================push======================================

push_branch(){
	for (( i = 0; i < ${#REPO_URL[@]}; i++ )); do
		repo_local_name=${REPO_URL_NAME[$i]}-$1;

		if [[ -d $repo_local_name ]]; then
			cd $repo_local_name;
			
			status=`git status`;
			if [[ $status == *"nothing to commit"*  ]]; then
				echo "$target_dir_name 暂时没有可以提交的！";
			else
				git pull;
				git add .;
				git commit -m "add";
				git push;
			fi
			cd ..
		else
			echo "$repo_local_name 分支不存在！"
		fi
	done
}	

operation_push(){
	
	branch=$1;
	echo $branch;

	if [[ $branch == 2 ]]; then #全部分支
		for i in ${REPO_BRANCH[@]}; do
			push_branch $i
		done
		return;
	fi

	if [[ $branch == 0 || $branch == 1 ]]; then #指定分支
		push_branch ${REPO_BRANCH[$branch]}
	fi
}

# ==================================del======================================

push_del(){
	for (( i = 0; i < ${#REPO_URL[@]}; i++ )); do
		repo_local_name=${REPO_URL_NAME[$i]}-$1;
		if [[ -d $repo_local_name ]]; then
			rm -rf $repo_local_name;
		else
			echo "$repo_local_name 分支目录不存在！";
		fi
	done
}	

operation_del(){
	
	branch=$1;
	echo $branch;

	if [[ $branch == 2 ]]; then #全部分支
		for i in ${REPO_BRANCH[@]}; do
			push_del $i
		done
		return;
	fi

	if [[ $branch == 0 || $branch == 1 ]]; then #指定分支
		push_del ${REPO_BRANCH[$branch]}
	fi
}

# ================================== repo operation ======================================

repo_operation(){
	chooseOperationType
	oper=$?;
	case $oper in
		1|2|3|4 ) 
			;;
		* ) echo "仓库操作选择不合法！"; exit;
			;;
	esac

	chooseBranch
	branch=$?;
	case $branch in
		1|2|0 ) 
			;;
		* ) echo "分支选择不合法！"; exit;
			;;
	esac

	if [[ $oper == 1 ]]; then # clone
		operation_clone $branch
	fi
	
	if [[ $oper == 2 ]]; then # pull
		operation_pull $branch
	fi

	if [[ $oper == 3 ]]; then # push
		operation_push $branch
	fi

	if [[ $oper == 4 ]]; then # del
		operation_del $branch
	fi
}
# ================================== gitee repo operation ======================================
gitee_clone(){
	for (( i = 0; i < ${#GITT_REPO_URL_NAME[@]}; i++ )); do
		repo_local_name="${GITT_REPO_URL_NAME[$i]} ${REPO_URL_NAME[i]}-$GITEE_DIR"
		git clone -b ${REPO_BRANCH[1]} $repo_local_name;
	done
}
gitee_push(){
	# 代码同步
	for i in ${REPO_URL_NAME[@]}; do
		source_dir_name=$i-${REPO_BRANCH[1]}; #master主干
		target_dir_name=$i-${GITEE_DIR};

		if [[ -e $source_dir_name && -e $target_dir_name ]]; then

			# 删除 GITEE 分支的仓库内容
			cd $target_dir_name;
			for subFile in `ls`; do
				rm -rf $subFile;
			done
			cd ..;
			# 复制 master 代码到 gitee 
			cd $source_dir_name;
			cp -r `ls | grep -v .git | xargs` "../$target_dir_name";
			cd ..
		fi
	done

	# 代码提交
	for i in ${REPO_URL_NAME[@]}; do
		target_dir_name=$i-${GITEE_DIR};

		if [[ -d $target_dir_name ]]; then
			cd $target_dir_name;
			
			status=`git status`;
			if [[ $status == *"nothing to commit"*  ]]; then
				echo "$target_dir_name 暂时没有可以提交的！";
			else
				git pull;
				git add .;
				git commit -m "add";
				git push;
			fi
			cd ..
		else
			echo "$target_dir_name 分支不存在！"
		fi
	done	
}
gitee_del(){
	for (( i = 0; i < ${#REPO_URL[@]}; i++ )); do
		repo_local_name=${REPO_URL_NAME[$i]}-$GITEE_DIR;
		if [[ -d $repo_local_name ]]; then
			rm -rf $repo_local_name;
		else
			echo "$repo_local_name 分支目录不存在！";
		fi
	done
}

# ================================== gitee repo operation ======================================

gitee_operation(){
	chooseOperationType
	oper=$?;
	case $oper in
		1|2|3|4 ) 
			;;
		* ) echo "仓库操作选择不合法！"; exit;
			;;
	esac

	if [[ $oper == 1 ]]; then # clone
		gitee_clone
	fi
	
	if [[ $oper == 2 ]]; then # pull
		echo "暂时不支持！"
		exit;
	fi

	if [[ $oper == 3 ]]; then # push
		gitee_push
	fi

	if [[ $oper == 4 ]]; then # del
		gitee_del
	fi
}

# ================================== gitbook operation ======================================

chooseGitBookOperation(){
	read -p "选择GitBook操作[install:1,build:2,同步到gh-pages分支:3]? " value;
	return $value;
}

gitbookInstall(){
	for i in ${REPO_URL_NAME[@]}; do
		source_dir_name=$i-${REPO_BRANCH[0]};
	
		if [[ -d $source_dir_name ]]; then
			gitbook install ./$source_dir_name;
		fi
	done	
}


# ================================== GitBook install ======================================

gitbook_install(){
	for i in ${REPO_URL_NAME[@]}; do
		source_dir_name=$i-${REPO_BRANCH[0]};

		if [[ -d $source_dir_name ]]; then
			gitbook install ./$source_dir_name;
		else
			echo "$source_dir_name 分支目录不存在！"
		fi
	done
}

# ================================== GitBook build ======================================
gitbook_build(){

	for i in ${REPO_URL_NAME[@]}; do
		source_dir_name=$i-${REPO_BRANCH[0]};
		tmp_target_dir_name="$source_dir_name$TEMP_DIR_NAME";

		# 删除零时文件夹
		if [[ -e $tmp_target_dir_name ]]; then
			rm -rf $tmp_target_dir_name;
		fi

		if [[ -d $source_dir_name ]]; then
			gitbook build ./$source_dir_name ./$tmp_target_dir_name;
		else
			echo "$source_dir_name 分支目录不存在！"
		fi
	done
}

# ================================== GitBook 同步 ======================================

# 复制文件位置
copyTempFileToBranch(){
	mp_target_dir_name=$1;
	target_dir_name=$2;
	cp -r $mp_target_dir_name/. $target_dir_name
}

# 删除文件夹中所有的文件
delDirFiles(){
	echo $1;
	cd $1;

	for subFile in `ls`; do
		if [[ $1 == *"-${REPO_BRANCH[1]}" ]]; then
			rm -rf $subFile;
		fi
	done
	cd ..;
}

# 删除指定分支中的文件
delLocalOneBranchFiles(){
	if [[ -d $1 ]]; then
		delDirFiles $1;
	fi
}

gitbook_gh-pages(){
	can_update=0;
	for i in ${REPO_URL_NAME[@]}; do
		source_dir_name=$i-${REPO_BRANCH[0]};
		tmp_target_dir_name="$source_dir_name$TEMP_DIR_NAME";

		if [[ -e $tmp_target_dir_name ]]; then
			can_update=1
		fi
	done

	if [[ $can_update == 0 ]]; then
		echo "请先 build！";
		exit;
	fi

	for i in ${REPO_URL_NAME[@]}; do
		source_dir_name=$i-${REPO_BRANCH[0]};
		tmp_target_dir_name="$source_dir_name$TEMP_DIR_NAME";
		target_dir_name=$i-${REPO_BRANCH[1]};

		if [[ -e $tmp_target_dir_name ]]; then
			
			DIRECTORY=$tmp_target_dir_name
			if [[ "`ls -A $DIRECTORY`" = "" ]]; then
			    echo "$tmp_target_dir_name 内容为空！";
				rm -rf $tmp_target_dir_name;
			else
				echo "$tmp_target_dir_name 内容不会空，正在同步！";
				delLocalOneBranchFiles $target_dir_name; # 删除分支 gh-pages 文件夹中的文件
			    copyTempFileToBranch $tmp_target_dir_name $target_dir_name; # 复制 tmp -> gh-pages 文件夹中文件
			    rm -rf $tmp_target_dir_name; # 删除零时文件夹 tmp
			fi
		else
			echo "不存在：$tmp_target_dir_name 文件夹！"
		fi
	done	
}

# ================================== GitBook build ======================================
gitbook_operation(){
	chooseGitBookOperation
	oper=$?

	case $oper in
		1|2|3 ) 
			;;
		* ) echo "GitBook操作选择不合法！"; exit;
			;;
	esac

	if [[ $oper == 1 ]]; then # 安装依赖
		gitbook_install
	fi

	if [[ $oper == 2 ]]; then # 编译
		gitbook_build
	fi

	if [[ $oper == 3 ]]; then # 同步到gh-pages分支
		gitbook_gh-pages
	fi
}

# ========== 帮助文档 ==========

# 这个选项关闭吧,否则$1无定义它报语法错.影响视觉.
#set -o nounset

help() { 
   cat <<- EOF
   -h --help        打印本帮助文档并退出
   -init            初始化环境
   -r --repo        GitHub 仓库操作
   -ge --gitee      Gitee 仓库操作
   -g --gitbook     GitBook 操作
EOF
   exit 0
}

case $1 in
	-h|--help )
		help
	;;
	-init )
		creatRootDir
	;;
	-r|--repo )
		checkEnv
		repo_operation
	;;
	-g|--gitbook )
		checkEnv
		gitbook_operation
	;;
	-ge|--gitee )
		checkEnv
		gitee_operation
	;;
	* )
		exit;
	;;
esac