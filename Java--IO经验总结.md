<font color=#ff0000 size=3 face="黑体">
###一些网站看到的经验总结
</font>
>引用：http://www.programcreek.com/2011/03/fileoutputstream-vs-filewriter/
####  Using FileOutputStream:
	File fout = new File(file_location_string);
	FileOutputStream fos = new FileOutputStream(fout);
	BufferedWriter out = new BufferedWriter(new OutputStreamWriter(fos));
	out.write("something");
####  Using FileWriter:
	FileWriter fstream = new FileWriter(file_location_string);
	BufferedWriter out = new BufferedWriter(fstream);
	out.write("something");
####  From Java API Specification:
>FileOutputStream is meant for writing streams of raw bytes such as image data. For writing streams of characters, consider using FileWriter.
>
如果您熟悉设计模式,FileWriter实际上是一个典型的使用装饰模式。我已经使用一个简单的教程展示装饰模式,因为它是非常重要的,许多设计非常有用。
FileOutputStream应用之一是将文件转换为一个字节数组