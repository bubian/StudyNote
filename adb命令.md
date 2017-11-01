####<font color=#0099ff>adb 分析内存泄漏：</font>
----
	1)back退出不应存在内存泄露，简单的检查办法是在退出应用后，用命令`adb shell dumpsys meminfo + 应用包名  查看 "Activities Views" 是否为零.
	2)多次进入退出后的占用内存`TOTAL`不应变化太大.

####<font color=#0099ff>adb 分析内存泄漏：</font>	
----
	1)验证可通过命令"adb shell dumpsys gfxinfo + 应用包名-cmd trim 5"后，再）用命令`adb shell dumpsys meminfo 应用包名`查看内存大小.
	
####<font color=#0099ff>adb 查看apk信息(版本号，权限，AndroidManifest等信息)：</font>

adb shell dumpsys package  + 包名
