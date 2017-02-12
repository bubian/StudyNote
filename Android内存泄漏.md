####<font color=#0099ff size=5 face="黑体">说明：</font>
<font color=#0099ff size=3 face="黑体">

Android 编程所使用的 Java 是一门使用垃圾收集器（GC, garbage collection）来自动管理内存的语言，它使得我们不再需要手动调用代码来进行内存回收。那么它是如何判断的呢？
简单说，如果一个对象，从它的根节点开始不可达的话，那么这个对象就是没有引用的了，是会被垃圾收集器回收的，其中，所谓的 “根节点” 往往是一个线程，比如主线程。因此，如果一个对象从它的根节点开始是可达的有引用的，但实际上它已经没有再使用了，是无用的，这样的对象就是内存泄漏的对象，它会在内存中占据我们应用程序原本就不是很多的内存，导致程序变慢，甚至内存溢出（OOM）程序崩溃。   
内存泄漏的原因并不难理解，但仅管知道它的存在，往往我们还是会不知觉中写出致使内存泄漏的代码。在 Android 编程中，也是有许多情景容易导致内存泄漏，以下将一一列举一些我所知道的内存泄漏案例，从这些例子中应该能更加直观了解怎么导致了内存泄漏，从而在编程过程中去避免
</font>
---
###<font color=#000000 size=4 face="黑体">静态变量造成内存泄漏</font>

静态变生命周期：
	
	静态变量的生命周期，起始于类的加载，终止于类的释放。对于 Android 而言，程序也是从一个 main 方法进入，开始了主线程的工作，
	如果一个类在主线程或旁枝中被使用到，它就会被加载，反过来说，假如一个类存在于我们的项目中，但它从未被我们使用过，算是个孤岛，
	这时它是没有被加载的。一旦被加载，只有等到我们的 Android 应用进程结束它才会被卸载。

例子：在 Activity 中声明一个静态变量引用了 Activity 自身，就会造成内存泄漏
    
	public class LeakActivity extends AppCompatActivity {
 
    	private static Context sContext;
 
	    @Override protected void onCreate(Bundle savedInstanceState) {
	        super.onCreate(savedInstanceState);
	        setContentView(R.layout.activity_leak);
	        sContext = this;
    	}
	}
	这样的代码会导致当这个 Activity 结束的时候，sContext 仍然持有它的引用，致使 Activity 无法回收（因为，类卸载是在进程结束的时候，
	Activity结束了，但是这时类并没有卸载，sContext是静态变量，生命周期和类一样，所以这时sContext依然对当前Activity持有引用，更加垃圾回收的原则，
	这时的Activity并不会被回收）。
	解决办法就是在这个 Activity 的 onDestroy 时将 sContext 的值置空，或者避免使用静态变量这样的写法.

###<font color=#000000 size=4 face="黑体">非静态内部类和匿名内部类造成内存泄漏</font>
例子1：Hander内部类引起的内存泄漏：

	private Handler mHandler = new Handler() {
	    @Override public void handleMessage(Message msg) {
	        super.handleMessage(msg);
	    }
	};
	
	由于在 Java 中，非静态内部类（包括匿名内部类，比如这个 Handler 匿名内部类）会引用外部类对象（比如 Activity，非静态内部类默认会持有一个外部类的索引，
	这样内部类才能够直接访问外部类的变量等），而静态的内部类则不会引用外部类对象（所以静态内部类不能直接访问外部类的非静态的成员变量）。
	所以这里 Handler 会引用 Activity 对象，当它使用了 postDelayed 的时候，如果 Activity 已经 finish 了，而这个 handler 仍然引用着这个 Activity 
	就会致使内存泄漏，因为这个 handler 会在一段时间内继续被 main Looper 持有，导致引用仍然存在，在这段时间内，如果内存吃紧至超出，就很危险了。
解决办法：使用静态内部类加 WeakReference
	
	private StaticHandler mHandler = new StaticHandler(this);
	 
	public static class StaticHandler extends Handler {
	    private final WeakReference mActivity;
	 
	    public StaticHandler(Activity activity) {
	        mActivity = new WeakReference(activity);
	    }
	 
	    @Override public void handleMessage(Message msg) {
	        super.handleMessage(msg);
	    }
	}
	使用静态内部类，就不会持有外部类对象，但是要访问外部类成员变量，还是需要外部类对象，那怎么办呢？这是就可以用WeakReference来创建一个外部对象的弱引用。
	至于为什么这样可以解决内存泄漏，请查看WeakReference用法。

例子2：如果一个变量，既是静态变量，而且是非静态的内部类对象，那么也会造成内存泄漏

	public class LeakActivity extends AppCompatActivity {
	 
	    private static Hello sHello;
	 
	    @Override protected void onCreate(Bundle savedInstanceState) {
	        super.onCreate(savedInstanceState);
	        setContentView(R.layout.activity_leak);
	 
	        sHello = new Hello();
	    }
	 
	    public class Hello {}
	}

	注意，这里我们定义的 Hello 虽然是空的，但它是一个非静态的内部类，所以它必然会持有外部类即 LeakActivity.this 引用，导致 sHello 这个静态变量一直持有这个Activity，于是结果就和第一个例子一样，Activity 无法被回收。

###<font color=#000000 size=4 face="黑体">资源未关闭引起的内存泄漏</font>

	当使用了BraodcastReceiver、Cursor、Bitmap等资源时，当不需要使用时，需要及时释放掉，若没有释放，则会引起内存泄漏。\
