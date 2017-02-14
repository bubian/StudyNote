###查看某个App的进程
ps |grep 进程名
cat /proc/进程号/oom_adj 查看进程优先级值（-20 — 19）

###ps查看进程
ps -ef
ps -aux
ps | grep 进程名

###查看某个App的进程
kill -s 9 pid(进程号)

	其中-s 9 制定了传递给进程的信号是９，即强制、尽快终止进程。各个终止信号及其作用如下。
	
	Signal	Description	Signal number on Linux x86[1]

	SIGABRT	Process aborted	6
	SIGALRM	Signal raised by alarm	14
	SIGBUS	Bus error: "access to undefined portion of memory object"	7
	SIGCHLD	Child process terminated, stopped (or continued*)	17
	SIGCONT	Continue if stopped	18
	SIGFPE	Floating point exception: "erroneous arithmetic operation"	8
	SIGHUP	Hangup	1
	SIGILL	Illegal instruction	4
	SIGINT	Interrupt	2
	SIGKILL	Kill (terminate immediately)	9
	SIGPIPE	Write to pipe with no one reading	13
	SIGQUIT	Quit and dump core	3
	SIGSEGV	Segmentation violation	11
	SIGSTOP	Stop executing temporarily	19
	SIGTERM	Termination (request to terminate)	15
	SIGTSTP	Terminal stop signal	20
	SIGTTIN	Background process attempting to read from tty ("in")	21
	SIGTTOU	Background process attempting to write to tty ("out")	22
	SIGUSR1	User-defined 1	10
	SIGUSR2	User-defined 2	12
	SIGPOLL	Pollable event	29
	SIGPROF	Profiling timer expired	27
	SIGSYS	Bad syscall	31
	SIGTRAP	Trace/breakpoint trap	5
	SIGURG	Urgent data available on socket	23
	SIGVTALRM	Signal raised by timer counting virtual time: "virtual timer expired"	26
	SIGXCPU	CPU time limit exceeded	24
	SIGXFSZ	File size limit exceeded	25

Linux AM命令
	
	am命令：在Android系统中通过adb shell 启动某个Activity、Service、拨打电话、启动浏览器等操作Android的命令.其源码在Am.java中，在shell环境下执行am命令实际是启动一个线程执行Am.java中的主函数（main方法），am命令后跟的参数都会当做运行时参数传递到主函数中，主要实现在Am.java的run方法中。

	拨打电话
	命令：am start -a android.intent.action.CALL -d tel:电话号码
	示例：am start -a android.intent.action.CALL -d tel:10086

	打开一个网页
	命令：am start -a android.intent.action.VIEW -d 网址
	示例：am start -a android.intent.action.VIEW -d http://www.skyseraph.com

	启动一个服务
	命令：am startservice <服务名称>
	示例：am startservice -n com.android.music/ com.android.music.MediaPlaybackService

