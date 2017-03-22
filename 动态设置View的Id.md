###动态设置自定义View的Id

>第一种：使用系统的方法

	myView.setId(View.generateViewId())
	
缺点：在sdk17（4.2.2）以上才可以使用myView.setId(View.generateViewId())才行，为了兼容，里面的id必须使用静态int类型。

>第二种：自己写一个工具类：

public class IdiUtils {  
  
    private static final AtomicInteger sNextGeneratedId = new AtomicInteger(1);  
		public static int generateViewId() {  
		    for (;;) {  
		        final int result = sNextGeneratedId.get();  
		        // aapt-generated IDs have the high byte nonzero; clamp to the range under that.  
		        int newValue = result + 1;  
		        if (newValue > 0x00FFFFFF) newValue = 1; // Roll over to 1, not 0.  
		        if (sNextGeneratedId.compareAndSet(result, newValue)) {  
		            return result;  
		        }  
		    }  
		}  
	} 


>第三种：使用配置文件

	在res/values/下添加ids.xml(名字可随意)文件
	<?xml version="1.0" encoding="utf-8"?>
	<resources>
	    <item name="my_view" type="id" />
	</resources>

	然后在代码中做如下设置即可：
	my_view.setId(R.id.my_view);