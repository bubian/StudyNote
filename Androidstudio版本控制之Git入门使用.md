##Android Studio版本控制之GitHub入门篇

准备：  
--------自行装好Android Studio和Git，然后在Android Studio设置里面把git.exe添加到git版本控制一栏。   
--------git环境变量配置，方便命令行使用。    
--------GitHub账号注册和创建SSH Key  
参考：http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000

###Git入门使用——建立本地仓库

首先我们得建立一个仓库来存放我们需要控制的东西，这里我在dos命令行完成这些操作，如果不能执行git命令，请检查git环境变量是否配置好。

				G:\GitHub\MrPds-git    ————当前所在的磁盘目录  
				λ git add readme.text  ————当前输入的命令

1. 建立本地仓库:   
 				
		新建一个目录作为仓库的文件存储
		        G:\GitHub   
		        λ mkdir MrPds-git      ————在GitHub目录下新建MrPds-git目录 
		现在将该目录变成一个真正的能进行版本控制的仓库————git初始化 
			    G:\GitHub\MrPds-git   
		        λ git init             ————在目录下会多一个隐藏的.git目录	
	  
2. 添加文件，提交文件，查看文件不同:   
 				
		在仓库里面新建一个文件
		        G:\GitHub\MrPds-git(master)   ————仓库初始化后默认是master主分支
		        λ echo first file > readme.txt      
		添加文件，执行该命令后，文件被放在了缓存区 
			    G:\GitHub\MrPds-git(master)   
		        λ git add readme.txt   		
        提交文件，执行该命令后，文件被提交到版本库 
			    G:\GitHub\MrPds-git(master)   
		        λ git commit -m "MrPds-first-commit"  
        查看文件不同，查看本地文件和版本库里的文件的不同 
			    G:\GitHub\MrPds-git(master)   
		        λ git diff file	
3. 查看当前仓库的状态 
 			
		        G:\GitHub\MrPds-git(master)   
		        λ git status   
		一般会有这几种状态：  
			版本库添加了文件或者文件被改动过等：  
				On branch master   ————在哪个分支
				Your branch is ahead of 'origin/master' by 1 commit. ———— 执行这个命令前，我在master分支提交一个文件
				  (use "git push" to publish your local commits)     ———— 提示可以用push来发布你的提交到远程仓库上
				Changes not staged for commit:                       ———— 版本库状态已经改变但是没有提交
				  (use "git add <file>..." to update what will be committed)  ———— 把要提交的文件添加到缓存区
				  (use "git checkout -- <file>..." to discard changes in working directory) ———— 这个命令可以将缓存区的内容

                modified:   Mr.txt     —————被改变的文件   
		    改动的文件被添加到缓存区：
                On branch master
				Your branch is ahead of 'origin/master' by 1 commit.
				(use "git push" to publish your local commits)
				Changes to be committed:                      
				(use "git reset HEAD <file>..." to unstage)   ———— 该命令可以用于回退版本
				
				    modified:   Mr.txt     
            添加的文件被提交到版本库后：
				On branch master
				Your branch is ahead of 'origin/master' by 1 commit.
				  (use "git push" to publish your local commits)
				nothing to commit, working directory clean ———— 没有需要提交的，工作目录干净，意思就是说工作目录没有需要添加，提交的文件

4. 版本回退———reset，log ，reflog     
		  
           查看历史记录：git log / git relog 
				commit 903c85700afb2993b67d99ad33e8b5ce665fe44c —— 提交的ID，一般钱7位可用于来回退版本
				Author: pdview <——————@qq.com>
				Date:   Sun Jul 17 11:45:31 2016 +0800
				
				    ggg —— 上面commit命令-m后面的字符串，随便写，用于说明。
				
				commit d24c29fb8a36a59ca272c793e484373485fa4fb4
				Author: pdview <——————@qq.com>
				Date:   Sat Jul 16 10:57:41 2016 +0800
				
				    MrPds-first-commit	 
     	
			版本回退： git reset HEAD~100
			说明：在Git中，用HEAD表示当前版本，也就是最新的提交），上一个版本就是HEAD^，上上一个版本就是HEAD^^，当然往上100个版本写100个^比较容易数不过来，所以写成HEAD~100。
				
			执行回退命令：git reset --hard HEAD^^或者回退到具体的版本号版本，git reset --hard 903c857

			注意：git reset --hard HEAD~100是回退到某个以前的版本，当我们

5. 撤销提交的操作———git reset --mixed HEAD~100

		如果你不小心添加文件并且提交到了版本库，但是现在你想把文件退回工作区重新添加和提交是，就得用这种办法了，HEAD~100就是你回退多少步。
6. 撤销修改———git checkout -- file  ————  可以丢弃工作区的修改  

		命令git checkout -- readme.txt意思就是，把readme.txt文件在工作区的修改全部撤销，这里有两种情况：
		
		一种是readme.txt自修改后还没有被放到暂存区，现在，撤销修改就回到和版本库一模一样的状态；
		
		一种是readme.txt已经添加到暂存区后，又作了修改，现在，撤销修改就回到添加到暂存区后的状态。
		
		总之，就是让这个文件回到最近一次git commit或git add时的状态。
7. 删除文件———git rm file  ————  然后提交就可以了  
  
       如果是误删，还没有提交的情况下，这是版本库里面还有，可以checkout来恢复。
8. 创建分支并切换到创建的分支——— git checkout -b branch 

	    G:\GitHub\MrPds-git(master)   
        λ git checkout -b develop  ———— 创建开发分支 也可以用git branch develop创建分支，用git checkout develop切换分支 说明：当创建了新的分支，当你在新的分支里面对文件进行修改并提交到版本库后，这个改变之后存在于你当前开发的分支，比如develop，而其主分支或者其它分支的版本并没有发生改变，但你在develop下修改文件并提交到版本库后，你切换到其它分支查看你在develop分支下修改的文件发现文件并没有被改变，如果你想把其它分支修改的内容合并到主分支上，那么就要进行分支合并。简单的情况下，git执行快速合并，只需要移动指向分支的指针就可以了，是非常快的。
9. 合并某分支到当前分支——— git merge <name>   
       合并分支最快的就是快速合并的方式，直接将当前分支指针指向最新的分支上就可以了。
10. 删除分支——— git branch -d <name>		
11. 存储工作现场——— stash功能  
    存储当前工作区改变的文件，比如在develop分支下执行 git stash命令，执行该命令后develop工作就干净了，就相当于和develop分支版本库里的内容一样了。
    然后切换到master分支去做其它的事情，等做完了再回到develop，这时需要恢复之前修改的文件，执行git stash apply和git stash pop都可以恢复，区别就是： 
  
    用git stash apply恢复，但是恢复后，stash内容并不删除，你需要用git stash drop来删除；
	另一种方式是用git stash pop，恢复的同时把stash内容也删了  
 
    如果不记得要恢复的工作现场了，可以用 git stash list查看	

12. 远程仓库——— github 
    
	    第一步：到github官网上注册注册账号和创建SSH Key  
	    第二步：在自己的账号下创建一个远程仓库。  
		第三步：将本地仓库和远程仓库关联：
			 G:\GitHub\MrPds-git(master)   
		     λ git remote add origin git@github.com:yourname/MrPds.git
					git@github.com:yourname/MrPds.git ———— 远程仓库的地址
					yourname ———— 你的账号
			    
		第四步：推送本地仓库内容到远程仓库：
			 G:\GitHub\MrPds-git(master)   
		     λ git push -u origin master

		把本地库的内容推送到远程，用git push命令，实际上是把当前分支master推送到远程。
	
		由于远程库是空的，我们第一次推送master分支时，加上了-u参数，Git不但会把本地的master分支内容推送的远程新的master分支，还会把本地的master分支和远程的master分支关联起来，在以后的推送或者拉取时就可以简化命令。
		
		推送成功后，可以立刻在GitHub页面中看到远程库的内容已经和本地一模一样：

12. 同步分支——— github   
	    在本地用命令创建分支，然后同步到github上： 
	
	      现在新建一个分支：
			 G:\GitHub\MrPds-git(master)   
		     λ git checkout -b newbranch
		  把分支推送到github上：
			 G:\GitHub\MrPds-git(newbranch)   
		     λ git push origin newbranch  ———— origin就是表示远程仓库
          现在你去github上看就多了newbranch这个分支了，当然你也可以在github上创建分支，然后合并到本地来。
13. clone仓库——— 这个不多讲了   

         git clone addrass <目录> ———— 目录可选，不填就是当前目录下
15. Android Studio使用git版本控制并同步远程仓库——github   
    第一种：不带版本控制的Android工程

		这就是我们平时用Android Studio直接创建一个工程，这种情况下，我们可以命令行切换到工程目录下，执行git init手动将工程目录变成带版本控制的，然后照到上面的步骤同步到远程仓库。
		当然最简单的方法是用Android Studio帮你完成这一切：VCS -> Import into Version Control -> Share Project on GitHub
		点击这个菜单就可以一键将工程发布到github上，同时将工程初始化带版本控制的，
	第二种：带版本控制的Android工程

		有时候可能会发现，从github上下载下来的工程导入Android Studio后没有显示版本控制的信息，如果你的Android Studio配置好了git，那么有可能是没有使能git版本控制，导入工程后，如果没有显示版本控制信息，你可以查看这个菜单下有没有这个选项：  
         VCS ——> Enable Version Control Intergration...,如果有点击打开就可以了。好!,现在就可以进行版本的更新，提交等操作了。   
	
		说明：有些时候，我们需要在公司，家里等不同的地方写代码然后提交到远程仓库，特别是想把自己平时积累的代码一点一滴记录下来又不想到处建工程的人来说很重要，
		这时你可以在不同的地方clone一份你的工程然后修改代码，提交代码，当然在一个分支上做很可能会有代码冲突，不过解决就好，如果你不想在主分支上做开发，那么可以创建分支，然后将分支的内容合并到主分支上就可以了。

16. 使用Android Studio操作版本控制  
    文件的提交，更新，比较等，这些就不讲了，跟svn差不多，Android Studio工具栏也有。
    
    从github上导入Android工程：
		Android Studio：File -> New -> Project from Version Control	-> GitHub	
  
    切换分支：
	    在VCS -> Git -> Branches..会显示本地分支，远程分支，最下方会显示当前处于的分支。通过在Local Branches点击分支并选择Checkout可以切换当前分支，并且切换后，工程就是分支下的内容，提交是也是提交到当前分支下，如需这要进行分支合并。