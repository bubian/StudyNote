####<font color=#0099ff size=5 face="黑体">说明：</font>
<font color=#0099ff size=3 face="黑体">
最近在公司做项目的时候，遇到一个内存泄漏的问题，由于代码有点多，有些代码又是别人之前写的，待功能开发完成后，以为事情就这么结束了，心
想总于可以休息了，不用加班了，但是在测试的时候，apk用就了就会出来程序崩溃的信息，弹出一个对话框，对就是ANR时弹出的那种对话框。刚开始
并没有注意，心想盒子用久了的正常现象吧，但是还是有点怀疑，比较才用一上午的嘛，后来我仿佛进播放器（我做的是一个回看播放器的功能），然后退出，再进，再退出，发现内存一直增加，并不会减少，按理退出播放器内存应该下降啊，就算我点了AS上的小车（gc回收）内存也没有任何变化，
于是我怀疑是内存泄漏的问题，由于代码比较多，不好定位问题，加上想学习一下MAT这个工具来分析一下内存泄漏。所以就开始的学习之旅。
</font>
---
###<font color=#000000 size=4 face="黑体">MAT简介</font>
MAT(Memory Analyzer Tool)，一个基于Eclipse的内存分析工具，是一个快速、功能丰富的JAVA heap分析工具，它可以帮助我们查找内存泄漏和减少内存消耗。
使用内存分析工具从众多的对象中进行分析，快速的计算出在内存中对象的占用大小，看看是谁阻止了垃圾收集器的回收工作，并可以通过报表直观的查看到可能造成这种结果的对象。
###<font color=#000000 size=4 face="黑体">MAT工具的下载</font>
[https://eclipse.org/mat/downloads.php](https://eclipse.org/mat/downloads.php "MAT的下载地址")
###<font color=#000000 size=4 face="黑体">常见的内存使用不当的情况</font>
请参照Android内存泄漏篇，链接：
###<font color=#000000 size=4 face="黑体">获取HPROF文件（head dump 堆快照）</font>
###<font color=#0099af size=3 face="黑体">DDMS导出</font>
