###优化APK大小

>优化资源：

	1.使用 tinyPNG 压缩图片大小
	2.有些图片换成 webP 格式，如背景图
	3.icon 图标仅保留一套，使用时将 ImageView 大小限制死。仅保留极个别不同分辨率的图标。
	4.部分icon 使用 svg 代替，少量

>优化布局：

	1.优化层级，减少布局嵌套
	2.一个界面一个界面的消除过渡绘制
	3.多使用 include 标签，重用布局
	4.不必要的布局使用 ViewStub 延迟加载（用的很少）
	5.将可复用资源抽取到对应的 res 文件中，如字符串，样式等

>优化代码：

	1.实体类去除没用到属性，并将属性设为 public ，去除 get / set 方法
	2.减少内部嵌套的实体类，尤其像 GsonFormat 这样的工具生成的实体类
	3.能服用的尽量复用。
	4.还剔除了一部分我自己常用的打包好的工具类中一些没调到的方法。
	5.不过，仅是减少几行代码，对 Apk 体积的优化成效甚微。