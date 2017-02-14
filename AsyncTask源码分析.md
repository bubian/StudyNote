#AsyncTask源码分析
---
<font color=#0000ff size=3 face="黑体">	
AsyncTask异步任务简介：
</font>
   001-实质：

	可以看成是：线程池+Handler,线程池执行耗时的后台任务,Handler处理UI交互。

   002-AsyncTask异步任务串行和并行

	android 1.5以前的时候execute是串行执行的
	android 1.6直到android 2.3.2被修改为并行执行，执行任务的线程池就是THREAD_POOL_EXECUTOR
	android 3.0以后，默认任务是串行执行的，如果想要并行执行任务可调用executeOnExecutor(Executor exec, Params.. params)

<font color=#0000ff size=3 face="黑体">	
AsyncTask异步任务初始化:
</font>

   001-创建AsyncTask任务对象

		private AsyncTask task = new  AsyncTask<Void, Integer, Boolean>() {
			//撤销异步任务
		    @Override
		    protected void onCancelled() {
		        super.onCancelled();
		    }
		
			//异步执行耗时任务
		    @Override
		    protected Boolean doInBackground(Void... params) {
		        return true;
		    }
		
			//处理任务执行完成后需要执行的操作
		    @Override
		    protected void onPostExecute(Boolean aBoolean) {
		        super.onPostExecute(aBoolean);
		    }
		
			//异步任务开始执行前需要执行的操作
		    @Override
		    protected void onPreExecute() {
		        super.onPreExecute();
		    }
		
			//主线程更新UI
		    @Override
		    protected void onProgressUpdate(Integer... values) {
		        super.onProgressUpdate(values);
		    }
		
		};

   002-AsyncTask类初始化

		静态数据初始化：

			0001-线程池相关变量初始化：
				
				private static final int CPU_COUNT = Runtime.getRuntime().availableProcessors();//根据cpu的大小来配置核心的线程
				private static final int CORE_POOL_SIZE = CPU_COUNT + 1;//核心线程数量
				private static final int MAXIMUM_POOL_SIZE = CPU_COUNT * 2 + 1;//线程池中允许的最大线程数目
				private static final int KEEP_ALIVE = 1;//空闲线程的超时时间
				
				private static final ThreadFactory sThreadFactory = new ThreadFactory() {
				    private final AtomicInteger mCount = new AtomicInteger(1);
				    public Thread newThread(Runnable r) {
				        return new Thread(r, "AsyncTask #" + mCount.getAndIncrement());
				    }
				};
				
				private static final BlockingQueue<Runnable> sPoolWorkQueue =
				        new LinkedBlockingQueue<Runnable>(128);
		
				public static final Executor THREAD_POOL_EXECUTOR
				        = new ThreadPoolExecutor(CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE,
				                TimeUnit.SECONDS, sPoolWorkQueue, sThreadFactory);

			0002-异步任务执行顺序队列变量初始化：
				 public static final Executor SERIAL_EXECUTOR = new SerialExecutor();//这个内部类实现了异步任务的串行执行。
				

		AsyncTask构造函数:

			public AsyncTask() {
		        mWorker = new WorkerRunnable<Params, Result>() {
		            public Result call() throws Exception {
		                mTaskInvoked.set(true);
		
		                Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND); //设置当前执行线程为后天线程
		                //noinspection unchecked
		                return postResult(doInBackground(mParams));//将结果发送出去
		            }
		        };

		    mFuture = new FutureTask<Result>(mWorker) {
				//任务执行完毕后会调用done方法
		        @Override
		        protected void done() {
		            try {
						//get()表示获取mWorker的call的返回值，即Result.然后看postResultIfNotInvoked方法
		                postResultIfNotInvoked(get());
		            } catch (InterruptedException e) {
		                android.util.Log.w(LOG_TAG, e);
		            } catch (ExecutionException e) {
		                throw new RuntimeException("An error occured while executing doInBackground()",
		                        e.getCause());
		            } catch (CancellationException e) {
		                postResultIfNotInvoked(null);
		            }
		        }
		    };
    }
			
<font color=#ff0000 size=3 face="黑体">
注意：AsyncTask的对象必须在主线程中实例化,原因下面讲解。
</font>
<font color=#0000ff size=3 face="黑体">	
执行AsyncTask异步任务：task.execute();
</font>

    public final AsyncTask<Params, Progress, Result> execute(Params... params) {
        return executeOnExecutor(sDefaultExecutor, params);
    }

	---sDefaultExecutor其实是一个SerialExecutor对象，实现了串行线程队列。params其实最终会赋给doInBackground方法去处理。

	executeOnExecutor(Executor exec,Params... params)方法：
		
	    public final AsyncTask<Params, Progress, Result> executeOnExecutor(Executor exec,
            Params... params) {
        if (mStatus != Status.PENDING) {
            switch (mStatus) {
                case RUNNING:
                    throw new IllegalStateException("Cannot execute task:"
                            + " the task is already running.");
                case FINISHED:
                    throw new IllegalStateException("Cannot execute task:"
                            + " the task has already been executed "
                            + "(a task can be executed only once)");
            }
        }

        mStatus = Status.RUNNING;

		onPreExecute();   //用于在异步任务执行前的初始化操作

        mWorker.mParams = params;
        exec.execute(mFuture); //exec是一个SerialExecutor对象，实现了串行线程队列

        return this;
    }

	这里要说明一下，AsyncTask的异步任务有三种状态

	PENDING 待执行状态。当AsyncTask被创建时，就进入了PENDING状态。
	RUNNING 运行状态。当调用executeOnExecutor，就进入了RUNNING状态。
	FINISHED 结束状态。当AsyncTask完成(用户cancel()或任务执行完毕)时，就进入了FINISHED状态。

	由于要执行onPreExecute()方法，在这个方法里面我们可能要去做有关UI操作的事情，所以这个操作必须在UI线程完成
	
<font color=#0000ff size=3 face="黑体">	
实现串行AsyncTask异步任务：exec.execute(mFuture);
</font>

    private static class SerialExecutor implements Executor {
        final ArrayDeque<Runnable> mTasks = new ArrayDeque<Runnable>();
        Runnable mActive;

        public synchronized void execute(final Runnable r) {
            mTasks.offer(new Runnable() {
                public void run() {
                    try {
                        r.run();
                    } finally {
                        scheduleNext();
                    }
                }
            });
            if (mActive == null) {
                scheduleNext();
            }
        }

        protected synchronized void scheduleNext() {
            if ((mActive = mTasks.poll()) != null) {
                THREAD_POOL_EXECUTOR.execute(mActive);
            }
        }
    }

	每执行一次execute方法，就会向mTasks（双端队列）的队尾插入一个Runnable对象。当第一次执行异步任务的时候，mActive等于null，
	所以会从队列里面取出第一个utureTask对象，THREAD_POOL_EXECUTOR（创建的线程池对象）调用execute方法开始执行。当前任务执行完成后
	会执行到刚才向mTasks添加的Runable的run方面，从而执行传递过来的FutureTask对象的run方法，FutureTask实现了RunnableFuture接口，RunnableFuture继承了Runable和Future接口。
	那么FutureTask对象的run方法里面都做了什么操作呢？

<font color=#0000ff size=3 face="黑体">	
执行耗时的后台任务：r.run;
</font>

	查看FutureTask源码里面的run方法：如下
	
    public void run() {
        if (state != NEW ||
            !UNSAFE.compareAndSwapObject(this, runnerOffset,
                                         null, Thread.currentThread()))
            return;
        try {
            Callable<V> c = callable;
            if (c != null && state == NEW) {
                V result;
                boolean ran;
                try {
                    result = c.call();
                    ran = true;
                } catch (Throwable ex) {
                    result = null;
                    ran = false;
                    setException(ex);
                }
                if (ran)
                    set(result);
            }
        } finally {
            // runner must be non-null until state is settled to
            // prevent concurrent calls to run()
            runner = null;
            // state must be re-read after nulling runner to prevent
            // leaked interrupts
            int s = state;
            if (s >= INTERRUPTING)
                handlePossibleCancellationInterrupt(s);
        }
    }

	检测当前状态是否是NEW,如果不是，说明任务已经完成或取消或中断，所以直接返回，那么什么时候状态被赋值为NEW的？请看调用AsyncTask构造函数里对FutureTask对象
	初始化，FutureTask构造函数如下：
	    public FutureTask(Callable<V> callable) {
		    if (callable == null)
		        throw new NullPointerException();
		    this.callable = callable;
		    this.state = NEW;       也是在异步任务未执行前初始化的。
    	}
	
	result = c.call()，c就是等于构造FutureTask对象时传递过来的WorkerRunnable对象，该对象实现了Callable接口里面的call方法，所有会去执行WorkerRunnable对象里的call()方法，
	该对象在AsyncTask构造函数里面初始化的一个内部类。如下：
	    public Result call() throws Exception {
            mTaskInvoked.set(true);

            Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND);
            //noinspection unchecked
            return postResult(doInBackground(mParams));
        }

	这里会去执行doInBackground方法，由于现在不是在主线程里面，所有可以在这里执行耗时的后台任务。那么在我们的doInBackground里面又需要做什么操作呢？
	
<font color=#0000ff size=3 face="黑体">	
执行我们的耗时后台任务：doInBackground（Void... params）
</font>	
        @Override
        protected Boolean doInBackground(Void... params) {
            		...
                publishProgress(progress);//必须执行这个方法，为什么请看publishProgress方法实现：
                	...
            return true;
        }

		
    protected final void publishProgress(Progress... values) {
        if (!isCancelled()) {
            getHandler().obtainMessage(MESSAGE_POST_PROGRESS,
                    new AsyncTaskResult<Progress>(this, values)).sendToTarget();
        }
    }		
	

<font color=#0000ff size=3 face="黑体">	
Handler消息处理:
</font>	
    private static class InternalHandler extends Handler {
        public InternalHandler() {
            super(Looper.getMainLooper());
        }

        @SuppressWarnings({"unchecked", "RawUseOfParameterizedType"})
        @Override
        public void handleMessage(Message msg) {
            AsyncTaskResult<?> result = (AsyncTaskResult<?>) msg.obj;
            switch (msg.what) {
                case MESSAGE_POST_RESULT:
                    // There is only one result
                    result.mTask.finish(result.mData[0]);
                    break;
                case MESSAGE_POST_PROGRESS:
                    result.mTask.onProgressUpdate(result.mData);
                    break;
            }
        }
    }

	此时会去调用onProgressUpdate方法,改方法里面我们进行UI更新操作。

<font color=#0000ff size=3 face="黑体">	
解释为什么AsyncTask的对象必须在主线程中实例化
</font>	
	这个还得从上面InternalHandler类说起，在API 22以下的代码，会发现它没有这个构造函数
	public InternalHandler() {
         super(Looper.getMainLooper());
    }
	而是使用默认的；默认情况下，Handler会使用当前线程的Looper，如果你的AsyncTask是在子线程创建的，那么很不幸，你的onProgressUpdate(Integer... values)和onPostExecute并非在UI线程执行，而是被Handler post到创建子线程执行；如果你在这两个线程更新了UI，那么直接导致崩溃。这也是大家口口相传的AsyncTask必须在主线程创建的原因。

	另外，AsyncTask里面的这个Handler是一个静态变量，也就是说它是在类加载的时候创建的；如果在你的APP进程里面，以前从来没有使用过AsyncTask，
	然后在子线程使用AsyncTask的相关变量，那么导致静态Handler初始化，如果在API 16以下，那么会出现上面同样的问题；这也就是AsyncTask必须在主线程初始化 的原因。

	事实上，在Android 4.1(API 16)以后，在APP主线程ActivityThread的main函数里面，直接调用了AscynTask.init函数确保这个类是在主线程初始化的，这样在使用异步任务之前，就能确保所用到的
	Handler用的是主线程的Looper；
	另外，init这个函数里面获取了InternalHandler的Looper，由于是在主线程执行的，因此，AsyncTask的Handler用的也是主线程的Looper。这个问题从而得到彻底的解决
	
		
<font color=#0000ff size=3 face="黑体">	
postResult(doInBackground(mParams));
</font>
	这时候，onProgressUpdate(Integer... values)在主线程更新UI，工作现在继续执行。
    private Result postResult(Result result) {
        @SuppressWarnings("unchecked")
        Message message = getHandler().obtainMessage(MESSAGE_POST_RESULT,
                new AsyncTaskResult<Result>(this, result));
        message.sendToTarget();
        return result;
    }

	异步任务执行完成，调用finish方法，


