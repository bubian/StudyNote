###<font color=#0099ff>IPC(进程间通信)：binder</font>

#####linux系统间的通信机制：
	传统的管道（Pipe）、信号（Signal）和跟踪（Trace）,这三项通信手段只能用于父进程与子进程之间，或者兄弟进程之间；后来又增加了命令管道（Named Pipe），
	使得进程间通信不再局限于父子进程或者兄弟进程之间，为了更好地支持商业应用中的事务处理，在AT&T的Unix系统V中，又增加了三种称为“System V IPC”的进程
	间通信机制，分别是报文队列（Message）、共享内存（Share Memory）和信号量（Semaphore）；后来BSD Unix对“System V IPC”机制进行了重要的扩充，
	提供了一种称为插口（Socket）的进程间通信机制。
#####Binder:
	Binder是一种进程间通信机制，它是一种类似于COM和CORBA分布式组件架构，通俗一点，其实是提供远程过程调用（RPC）功能。
#####Android里的Binder：
	由一系统组件组成，分别是Client、Server、Service Manager和Binder驱动程序，其中Client、Server和Service Manager运行在用户空间，
	Binder驱动程序运行内核空间。inder就是一种把这四个组件粘合在一起的粘结剂了，其中，核心组件便是Binder驱动程序了，
	Service Manager提供了辅助管理的功能，Client和Server正是在Binder驱动和Service Manager提供的基础设施上，进行Client-Server之间的通信。
			
							----------------------Binder模型图-------------------------

#####ServiceManager成为Android进程间通信（IPC）机制Binder守护进程分析：
	 
Service Manager在用户空间的源代码位于frameworks/base/cmds/servicemanager目录下，主要是由binder.h、binder.c和service_manager.c三个文件组成。
Service Manager的入口位于service_manager.c文件中。
main函数：

	int main(int argc, char **argv)  
	{  
		struct binder_state *bs;  
    	void *svcmgr = BINDER_SERVICE_MANAGER;  
  
    	bs = binder_open(128*1024);      //打开Binder设备文件
  
    	if (binder_become_context_manager(bs)) {     //向Binder驱动程序添加Binder上下文管理者（ServiceManager）,让ServiceManager成为守护进程。
        	LOGE("cannot become context manager (%s)\n", strerror(errno));  
        	return -1;  
    	}  
  
    	svcmgr_handle = svcmgr;  
    	binder_loop(bs, svcmgr_handler);  //三是进入一个无穷循环，充当Server的角色，等待Client的请求。
    	return 0;  
	}
 struct binder_state(frameworks/base/cmds/servicemanager/binder.c):

	struct binder_state  
	{  
		int fd;   //文件描述符,即表示打开的/dev/binder设备文件描述符

		void *mapped;  	//mapped是把设备文件/dev/binder映射到进程空间的起始地址。

		unsigned mapsize;  //mapsize是上述内存映射空间的大小
	}; 

binder_become_context_manager(定义frameworks/base/cmds/servicemanager/binder.h文件中):

	-#define BINDER_SERVICE_MANAGER ((void*) 0)
	解释：它表示ServiceManager的句柄为0。Binder通信机制使用句柄来代表远程接口，
	这个句柄的意义和Windows编程中用到的句柄是差不多的概念。前面说到，Service Manager在充当守护进程的同时，它充当Server的角色，
	当它作为远程接口使用时，它的句柄值便为0，这就是它的特殊之处，其余的Server的远程接口句柄值都是一个大于0 而且由Binder驱动程序自动进行分配的。

	int binder_become_context_manager(struct binder_state *bs)  
	{  
		 //这里通过调用ioctl文件操作函数来通知Binder驱动程序自己是守护进程，命令号是BINDER_SET_CONTEXT_MGR，没有参数。
    	return ioctl(bs->fd, BINDER_SET_CONTEXT_MGR, 0); 

	}
	
#####Android系统进程间通信（IPC）机制Binder中的Server和Client获得ServiceManager接口分析：

简介：
	ServiceManager在Binder机制中既充当守护进程的角色，同时它也充当着Server角色，然而它又与一般的Server不一样。
	对于普通的Server来说，Client如果想要获得Server的远程接口，那么必须通过ServiceManager远程接口提供的getService接口来获得，
	这本身就是一个使用Binder机制来进行进程间通信的过程。而对于Service Manager这个Server来说，Client如果想要获得ServiceManager远程接口，
	却不必通过进程间通信机制来获得，因为Service Manager远程接口是一个特殊的Binder引用，它的引用句柄一定是0。

获取Service Manager远程接口函数:defaultServiceManager();

	文件路径：rameworks/base/include/binder/IServiceManager.h
	sp<IServiceManager> defaultServiceManager()  
	{  
  
    	if (gDefaultServiceManager != NULL) return gDefaultServiceManager;  
  
    	{  
        	AutoMutex _l(gDefaultServiceManagerLock);  
        	if (gDefaultServiceManager == NULL) {  
            	gDefaultServiceManager = interface_cast<IServiceManager>(  
                ProcessState::self()->getContextObject(NULL));  
        	}  
    	}  
  
    	return gDefaultServiceManager;  
	} 
	
    gDefaultServiceManagerLock和gDefaultServiceManager是全局变量，定义在frameworks/base/libs/binder/Static.cpp文件中：

	------------------------------------uml图-------------------------------------------------------
	 IServiceManager类继承了IInterface类，而IInterface类和BpRefBase类又分别继承了RefBase类。在BpRefBase类中，
	有一个成员变量mRemote，它的类型是IBinder*，实现类为BpBinder，它表示一个Binder引用，引用句柄值保存在BpBinder类的mHandle成员变量中。
	BpBinder类通过IPCThreadState类来和Binder驱动程序并互，而IPCThreadState又通过它的成员变量mProcess来打开/dev/binder设备文件，
	mProcess成员变量的类型为ProcessState。ProcessState类打开设备/dev/binder之后，将打开文件描述符保存在mDriverFD成员变量中，以供后续使用。

gDefaultServiceManager = interface_cast<IServiceManager>(ProcessState::self()->getContextObject(NULL)); 

	ProcessState::self()

	首先是调用ProcessState::self函数，self函数是ProcessState的静态成员函数，它的作用是返回一个全局唯一的ProcessState实例变量，
	就是单例模式了，这个变量名为gProcess。如果gProcess尚未创建，就会执行创建操作，在ProcessState的构造函数中，
	会通过open文件操作函数打开设备文件/dev/binder，并且返回来的设备文件描述符保存在成员变量mDriverFD中。

	gProcess->getContextObject(NULL)
	
	获得一个句柄值为0的Binder引用，即BpBinder了，于是创建Service Manager远程接口的语句可以简化为：

	gDefaultServiceManager = interface_cast<IServiceManager>(new BpBinder(0));  

函数interface_cast<IServiceManager>:定义在framework/base/include/binder/IInterface.h文件中

	template<typename INTERFACE>  
	inline sp<INTERFACE> interface_cast(const sp<IBinder>& obj)  
	{  
    	return INTERFACE::asInterface(obj);  
	}

	这里的INTERFACE是IServiceManager，于是调用了IServiceManager::asInterface函数。
	IServiceManager::asInterface是通过DECLARE_META_INTERFACE(ServiceManager)
	宏在IServiceManager类中声明的，它位于framework/base/include/binder/IServiceManager.h文件中:DECLARE_META_INTERFACE(ServiceManager);

	展开即为：

	-#define DECLARE_META_INTERFACE(ServiceManager)                     \  
    static const android::String16 descriptor;                          \  
    static android::sp<IServiceManager> asInterface(                    \  
    const android::sp<android::IBinder>& obj);                          \  
    virtual const android::String16& getInterfaceDescriptor() const;    \  
    IServiceManager();                                                  \  
    virtual ~IServiceManager(); 

	IServiceManager::asInterface的实现是通过IMPLEMENT_META_INTERFACE(ServiceManager, "android.os.IServiceManager")宏定义的，
	它位于framework/base/libs/binder/IServiceManager.cpp文件中：

	IMPLEMENT_META_INTERFACE(ServiceManager, "android.os.IServiceManager");  展开为：

	-#define IMPLEMENT_META_INTERFACE(ServiceManager, "android.os.IServiceManager")                 \  
    const android::String16 IServiceManager::descriptor("android.os.IServiceManager");     \  
    const android::String16&                                   \  
    IServiceManager::getInterfaceDescriptor() const {                                      \  
    	return IServiceManager::descriptor;                                                    \  
    }                                                                                      \  
    android::sp<IServiceManager> IServiceManager::asInterface(                             \  
    const android::sp<android::IBinder>& obj)                                              \  
    {                                                                                      \  
    	android::sp<IServiceManager> intr;                                                     \  
    	if (obj != NULL) {                                                                     \  
    		intr = static_cast<IServiceManager*>(                                                  \  
    		obj->queryLocalInterface(                                                              \  
    		IServiceManager::descriptor).get());                                                   \  
    		if (intr == NULL) {                                                                    \  
    			intr = new BpServiceManager(obj);                                                      \  
    		}                                                                                      \  
    	}                                                                                      \  
    	return intr;                                                                           \  
    }                                                                                      \  
    IServiceManager::IServiceManager() { }                                                 \  
    IServiceManager::~IServiceManager() { }  

IServiceManager::asInterface的实现：
	
	android::sp<IServiceManager> IServiceManager::asInterface(const android::sp<android::IBinder>& obj)                                                
	{                                                                                       
    	android::sp<IServiceManager> intr;                                                      
      
    	if (obj != NULL) {                                                                       
        	intr = static_cast<IServiceManager*>(obj->queryLocalInterface(IServiceManager::descriptor).get());  
        	if (intr == NULL) {                  
            	intr = new BpServiceManager(obj);                                          
        	}                                            
    	｝  
    	return intr;                                    
	} 

	这里传进来的参数obj就则刚才创建的new BpBinder(0)了，BpBinder类中的成员函数queryLocalInterface继承自基类IBinder，
	IBinder::queryLocalInterface函数位于framework/base/libs/binder/Binder.cpp文件中：

回到defaultServiceManager函数中，最终结果为：

	gDefaultServiceManager = new BpServiceManager(new BpBinder(0));  

#####Android系统进程间通信（IPC）机制Binder中的Server启动过程源代码分析:

	Server获得了Service Manager远程接口之后，就要把自己的Service添加到Service Manager中去，然后把自己启动起来，等待Client的请求。

---------------------------------uml图-----------------------------------------------------

	BnMediaPlayerService并不是直接接收到Client处发送过来的请求，而是使用了IPCThreadState接收Client处发送过来的请求，
	而IPCThreadState又借助了ProcessState类来与Binder驱动程序交互。IPCThreadState接收到了Client处的请求后，
	就会调用BBinder类的transact函数，并传入相关参数，BBinder类的transact函数最终调用BnMediaPlayerService类的onTransact函数，
	于是，就开始真正地处理Client的请求了。

MediaPlayerService是如何启动的:

	启动MediaPlayerService的代码位于frameworks/base/media/mediaserver/main_mediaserver.cpp文件中

	int main(int argc, char** argv)  
	{  
    	sp<ProcessState> proc(ProcessState::self());  
    	sp<IServiceManager> sm = defaultServiceManager();  
    	LOGI("ServiceManager: %p", sm.get());  
    	AudioFlinger::instantiate();  
    	MediaPlayerService::instantiate();  
    	CameraService::instantiate();  
    	AudioPolicyService::instantiate();  
    	ProcessState::self()->startThreadPool();  
    	IPCThreadState::self()->joinThreadPool();  
	}

sp<ProcessState> proc(ProcessState::self());  

	这句代码的作用是通过ProcessState::self()调用创建一个ProcessState实例。ProcessState::self()是ProcessState类的一个静态成员变量，
	定义在frameworks/base/libs/binder/ProcessState.cpp文件中：

	sp<ProcessState> ProcessState::self()  
	{  
    	if (gProcess != NULL) return gProcess;  
      
    	AutoMutex _l(gProcessMutex);  
    	if (gProcess == NULL) gProcess = new ProcessState;  
    	return gProcess;  
	}

ProcessState的构造函数：

    ProcessState::ProcessState()  
    	: mDriverFD(open_driver())  
    	, mVMStart(MAP_FAILED)  ``
    	, mManagesContexts(false)  
    	, mBinderContextCheckFunc(NULL)  
    	, mBinderContextUserData(NULL)  
    	, mThreadPoolStarted(false)  
    	, mThreadPoolSeq(1)  
    {  
    	if (mDriverFD >= 0) {  
    	// XXX Ideally, there should be a specific define for whether we  
    	// have mmap (or whether we could possibly have the kernel module  
    	// availabla).  
   -#if !defined(HAVE_WIN32_IPC)  
    	// mmap the binder, providing a chunk of virtual address space to receive transactions.  
    	mVMStart = mmap(0, BINDER_VM_SIZE, PROT_READ, MAP_PRIVATE | MAP_NORESERVE, mDriverFD, 0);  
    	if (mVMStart == MAP_FAILED) {  
    	// *sigh*  
    	LOGE("Using /dev/binder failed: unable to mmap transaction memory.\n");  
    	close(mDriverFD);  
    	mDriverFD = -1;  
    }  
    -#else  
    	mDriverFD = -1;  
    -#endif  
    }  
    	if (mDriverFD < 0) {  
    	// Need to run without the driver, starting our own thread pool.  
    	}  
    }

	这个函数有两个关键地方，一是通过open_driver函数打开Binder设备文件/dev/binder，并将打开设备文件描述符保存在成员变量mDriverFD中；
	二是通过mmap来把设备文件/dev/binder映射到内存中。

先看open_driver函数的实现:

	static int open_driver()  
	{  
    	if (gSingleProcess) {  
        	return -1;  
    	}  
  
    	int fd = open("/dev/binder", O_RDWR);  
    	if (fd >= 0) {  
        	fcntl(fd, F_SETFD, FD_CLOEXEC);  
        	int vers;  
	-#if defined(HAVE_ANDROID_OS)  
        status_t result = ioctl(fd, BINDER_VERSION, &vers);  
	-#else  
        status_t result = -1;  
        errno = EPERM;  
	-#endif  
        if (result == -1) {  
            LOGE("Binder ioctl to obtain version failed: %s", strerror(errno));  
            close(fd);  
            fd = -1;  
        }  
        if (result != 0 || vers != BINDER_CURRENT_PROTOCOL_VERSION) {  
            LOGE("Binder driver protocol does not match user space protocol!");  
            close(fd);  
            fd = -1;  
        }  
	-#if defined(HAVE_ANDROID_OS)  
        size_t maxThreads = 15;  
        result = ioctl(fd, BINDER_SET_MAX_THREADS, &maxThreads);  
        if (result == -1) {  
            LOGE("Binder ioctl to set max threads failed: %s", strerror(errno));  
        }  
	-#endif  
          
    } else {  
        LOGW("Opening '/dev/binder' failed: %s\n", strerror(errno));  
    	}  
    	return fd;  
	}

	这个函数的作用主要是通过open文件操作函数来打开/dev/binder设备文件，然后再调用ioctl文件控制函数来分别执行
	BINDER_VERSION和BINDER_SET_MAX_THREADS两个命令来和Binder驱动程序进行交互，前者用于获得当前Binder驱动程序的版本号，
	后者用于通知Binder驱动程序，MediaPlayerService最多可同时启动15个线程来处理Client端的请求。

再接下来，就进入到MediaPlayerService::instantiate函数把MediaPlayerService添加到Service Manger中去了。
	这个函数定义在frameworks/base/media/libmediaplayerservice/MediaPlayerService.cpp文件中：

	void MediaPlayerService::instantiate() {  
    	defaultServiceManager()->addService(String16("media.player"), new MediaPlayerService());  
	}

BpServiceManger::addService的实现：
	这个函数实现在frameworks/base/libs/binder/IServiceManager.cpp文件中：

	class BpServiceManager : public BpInterface<IServiceManager>  
	{  
		public:  
    		BpServiceManager(const sp<IBinder>& impl) : BpInterface<IServiceManager>(impl)  
    		{  
    		}  
  
    	......  
  
    	virtual status_t addService(const String16& name, const sp<IBinder>& service)  
    	{  
        	Parcel data, reply;  
        	data.writeInterfaceToken(IServiceManager::getInterfaceDescriptor());  
        	data.writeString16(name);  
        	data.writeStrongBinder(service);  
        	status_t err = remote()->transact(ADD_SERVICE_TRANSACTION, data, &reply);  
        	return err == NO_ERROR ? reply.readExceptionCode()   
    	}  
  
    	......  
  
	};

	这里的Parcel类是用来于序列化进程间通信数据用的。

data.writeInterfaceToken(IServiceManager::getInterfaceDescriptor());  
	
	IServiceManager::getInterfaceDescriptor()返回来的是一个字符串，即"android.os.IServiceManager"

data.writeString16(name)：

	这里又是写入一个字符串到Parcel中去，这里的name即是上面传进来的“media.player”字符串。

data.writeStrongBinder(service)：

	这里定入一个Binder对象到Parcel去。我们重点看一下这个函数的实现，因为它涉及到进程间传输Binder实体的问题，比较复杂，需要重点关注，
	同时，也是理解Binder机制的一个重点所在。注意，这里的service参数是一个MediaPlayerService对象。

---------------------------------------------client-----------------------------------------------------

Android系统进程间通信（IPC）机制Binder中的Client获得Server远程接口过程源代码分析：
	
	IMediaDeathNotifier::getMeidaPlayerService（）
		--> sp<IServiceManager> sm = defaultServiceManager();
			相当于defaultServiceManager() = new BpServiceManager(new BpBinder(0)); 这里的0表示Service Manager的远程接口的句柄值是0。

BpServiceManager::getService的实现：
	class BpServiceManager : public BpInterface<IServiceManager>  
	{  
    	......  
  	
    	virtual sp<IBinder> getService(const String16& name) const  
    	{  
        	unsigned n;  
        	for (n = 0; n < 5; n++){  
            	sp<IBinder> svc = checkService(name);  
            	if (svc != NULL) return svc;  
            	LOGI("Waiting for service %s...\n", String8(name).string());  
            	sleep(1);  
       	 }  
        return NULL;  
    }  
  
    	virtual sp<IBinder> checkService( const String16& name) const  
    	{  
        Parcel data, reply;  
        data.writeInterfaceToken(IServiceManager::getInterfaceDescriptor());  
        data.writeString16(name);  
        remote()->transact(CHECK_SERVICE_TRANSACTION, data, &reply);  
        return reply.readStrongBinder();  
    	}  
  
    	......  
	};

	 这里的remote()返回的是一个BpBinder，于是，就进行到BpBinder::transact函数了

	uint32_t code, const Parcel& data, Parcel* reply, uint32_t flags)  
	{  
    	// Once a binder has died, it will never come back to life.  
    	if (mAlive) {  
        	status_t status = IPCThreadState::self()->transact(  
            mHandle, code, data, reply, flags);  
        	if (status == DEAD_OBJECT) mAlive = 0;  
        	return status;  
    	}  
  
    return DEAD_OBJECT;  
	} 

	  这里的mHandle = 0，code = CHECK_SERVICE_TRANSACTION，flags = 0

这里再进入到IPCThread::transact函数中：

	接下来 进入到waitForResponse(reply)函数中：

	在这个函数中由IPCThreadState::talkWithDriver与驱动程序进行交互。
	
	接下来 reply.readStrongBinder函数

	最后，函数调用： sMediaPlayerService = interface_cast<IMediaPlayerService>(binder) --> IMediaPlayerService::asInterface函数;  

	android::sp<IMediaPlayerService> IMediaPlayerService::asInterface(const android::sp<android::IBinder>& obj)  
	{  
    	android::sp<IServiceManager> intr;  
    	if (obj != NULL) {               
        	intr = static_cast<IMediaPlayerService*>(   
            obj->queryLocalInterface(IMediaPlayerService::descriptor).get());  
        	if (intr == NULL) {  
            	intr = new BpMediaPlayerService(obj);  
        	}  
    }  
    return intr;   
	}
	这里的obj就是BpBinder，而BpBinder::queryLocalInterface返回NULL，因此就创建了一个BpMediaPlayerService对象：

	intr = new BpMediaPlayerService(new BpBinder(handle));  


	因此，我们最终就得到了一个BpMediaPlayerService对象，达到我们最初的目标。
    有了这个BpMediaPlayerService这个远程接口之后，MediaPlayer就可以调用MediaPlayerService的服务了。

#####Android系统进程间通信Binder机制在应用程序框架层的Java接口源代码分析

ServiceManager.getIServiceManager():

	它的作用就是用来获取Service Manager的Java远程接口了，而这个函数又是通过ServiceManagerNative来获取Service Manager的Java远程接口的。

	public final class ServiceManager {  
    	......  
    	private static IServiceManager sServiceManager;  
    	......  
    	private static IServiceManager getIServiceManager() {  
        	if (sServiceManager != null) {  
            	return sServiceManager;  
        	}  
  
        	// Find the service manager  
        	sServiceManager = ServiceManagerNative.asInterface(BinderInternal.getContextObject());  
       		 return sServiceManager;  
    	}  
    	......  
	}

	如果其静态成员变量sServiceManager尚未创建，那么就调用ServiceManagerNative.asInterface函数来创建。在调用ServiceManagerNative.asInterface函数之前，
	首先要通过BinderInternal.getContextObject函数来获得一个BinderProxy对象

BinderInternal.getContextObject的实现:
	这个函数定义在frameworks/base/core/java/com/android/internal/os/BinderInternal.java文件中.

	public class BinderInternal {  
    	......  
    	public static final native IBinder getContextObject();  
      
    	......  
	}

	BinderInternal.getContextObject是一个JNI方法，它实现在frameworks/base/core/jni/android_util_Binder.cpp文件中：

	static jobject android_os_BinderInternal_getContextObject(JNIEnv* env, jobject clazz)  
	{  
    	sp<IBinder> b = ProcessState::self()->getContextObject(NULL);  
    	return javaObjectForIBinder(env, b);  
	}

	sp<IBinder> b = ProcessState::self()->getContextObject(NULL);相当于sp<IBinder> b = new BpBinder(0);

javaObjectForIBinder(env, b);

	接着调用javaObjectForIBinder把这个BpBinder对象转换成一个BinderProxy对象：

变量gBinderOffsets和gBinderProxyOffsets的定义。
	
	static struct bindernative_offsets_t  
	{  
    	// Class state.  
    	jclass mClass;  
    	jmethodID mExecTransact;  
  
    	// Object state.  
    	jfieldID mObject;  
  
	} gBinderOffsets;

	简单来说，gBinderOffsets变量是用来记录上面第二个类图中的Binder类的相关信息的，
	它是在注册Binder类的JNI方法的int_register_android_os_Binder函数初始化的：


	const char* const kBinderPathName = "android/os/Binder";  
  
	static int int_register_android_os_Binder(JNIEnv* env)  
	{  
    	jclass clazz;  
  
    	clazz = env->FindClass(kBinderPathName);  
    	LOG_FATAL_IF(clazz == NULL, "Unable to find class android.os.Binder");  
  
    	gBinderOffsets.mClass = (jclass) env->NewGlobalRef(clazz);  
    	gBinderOffsets.mExecTransact  = env->GetMethodID(clazz, "execTransact", "(IIII)Z");  
    	assert(gBinderOffsets.mExecTransact);  
  
    	gBinderOffsets.mObject  = env->GetFieldID(clazz, "mObject", "I");  
    	assert(gBinderOffsets.mObject);  
  
    	return AndroidRuntime::registerNativeMethods(  
        	env, kBinderPathName,  
        	gBinderMethods, NELEM(gBinderMethods));  
	}

gBinderProxyOffsets的定义：

	static struct binderproxy_offsets_t  
	{  
    	// Class state.  
    	jclass mClass;  
    	jmethodID mConstructor;  
    	jmethodID mSendDeathNotice;  
  
    	// Object state.  
    	jfieldID mObject;  
    	jfieldID mSelf;  
  
	} gBinderProxyOffsets;  

	  简单来说，gBinderProxyOffsets是用来变量是用来记录上面第一个图中的BinderProxy类的相关信息的，
	  它是在注册BinderProxy类的JNI方法的int_register_android_os_BinderProxy函数初始化的：

	const char* const kBinderProxyPathName = "android/os/BinderProxy";  
  
	static int int_register_android_os_BinderProxy(JNIEnv* env)  
	{  
    	jclass clazz;  
  
    	clazz = env->FindClass("java/lang/ref/WeakReference");  
    	LOG_FATAL_IF(clazz == NULL, "Unable to find class java.lang.ref.WeakReference");  
    	gWeakReferenceOffsets.mClass = (jclass) env->NewGlobalRef(clazz);  
    	gWeakReferenceOffsets.mGet  
        	= env->GetMethodID(clazz, "get", "()Ljava/lang/Object;");  
    	assert(gWeakReferenceOffsets.mGet);  
  
    	clazz = env->FindClass("java/lang/Error");  
    	LOG_FATAL_IF(clazz == NULL, "Unable to find class java.lang.Error");  
    	gErrorOffsets.mClass = (jclass) env->NewGlobalRef(clazz);  
      
    	clazz = env->FindClass(kBinderProxyPathName);  
    	LOG_FATAL_IF(clazz == NULL, "Unable to find class android.os.BinderProxy");  
  
    	gBinderProxyOffsets.mClass = (jclass) env->NewGlobalRef(clazz);  
    	gBinderProxyOffsets.mConstructor  
        	= env->GetMethodID(clazz, "<init>", "()V");  
    	assert(gBinderProxyOffsets.mConstructor);  
    	gBinderProxyOffsets.mSendDeathNotice  
        	= env->GetStaticMethodID(clazz, "sendDeathNotice", "(Landroid/os/IBinder$DeathRecipient;)V");  
    	assert(gBinderProxyOffsets.mSendDeathNotice);  
  
    	gBinderProxyOffsets.mObject  
        	= env->GetFieldID(clazz, "mObject", "I");  
    	assert(gBinderProxyOffsets.mObject);  
    	gBinderProxyOffsets.mSelf  
        	= env->GetFieldID(clazz, "mSelf", "Ljava/lang/ref/WeakReference;");  
    	assert(gBinderProxyOffsets.mSelf);  
  
    	return AndroidRuntime::registerNativeMethods(  
        	env, kBinderProxyPathName,  
        	gBinderProxyMethods, NELEM(gBinderProxyMethods));  
	} 
	
jobject object = (jobject)val->findObject(&gBinderProxyOffsets); 

	由于这个BpBinder对象是第一创建，它里面什么对象也没有，因此，这里返回的object为NULL。

object = env->NewObject(gBinderProxyOffsets.mClass, gBinderProxyOffsets.mConstructor);  

	这里，就创建了一个BinderProxy对象了。创建了之后，要把这个BpBinder对象和这个BinderProxy对象关联起来：

env->SetIntField(object, gBinderProxyOffsets.mObject, (int)val.get()); 

	就是通过BinderProxy.mObject成员变量来关联的了，BinderProxy.mObject成员变量记录了这个BpBinder对象的地址。

接下去，还要把它放到BpBinder里面去，下次就要使用时，就可以在上一步调用BpBinder::findObj把它找回来了：

	val->attachObject(&gBinderProxyOffsets, refObject,jnienv_to_javavm(env), proxy_cleanup);  

	最后，就把这个BinderProxy返回到android_os_BinderInternal_getContextObject函数，最终返回到最开始的ServiceManager.getIServiceManager函数中来了，
	于是，我们就获得一个BinderProxy对象了。

	sServiceManager = ServiceManagerNative.asInterface(BinderInternal.getContextObject()); 
	相当于sServiceManager = ServiceManagerNative.asInterface(new BinderProxy());

ServiceManagerNative.asInterface函数：
	public abstract class ServiceManagerNative ......{  
    	......  
    	static public IServiceManager asInterface(IBinder obj)  {  
        	if (obj == null) {  
            	return null;  
        	}  
        	IServiceManager in =  
            	(IServiceManager)obj.queryLocalInterface(descriptor);  
        	if (in != null) {  
            	return in;  
        	}  
  
        	return new ServiceManagerProxy(obj);  
    	}  
    	......  
	}

	  这里的参数obj是一个BinderProxy对象，它的queryLocalInterface函数返回null。因此，最终以这个BinderProxy对象为参数创建一个ServiceManagerProxy对象。

	sServiceManager = ServiceManagerNative.asInterface(new BinderProxy()); 相当于：
	sServiceManager = new ServiceManagerProxy(new BinderProxy());  

#####让系统启动我们定义的service：

	在frameworks/base/services/java/com/android/server/SystemServer.java文件中，定义了SystemServer类。SystemServer对象是在系统启动的时候创建的，
	它被创建的时候会启动一个线程来创建我们的service，比如现在我要启动一个叫HelloWord的service服务，并且把它添加到ServiceManager中去。

	public class HelloService extends IHelloService.Stub {  
    	private static final String TAG = "HelloService";  
  
    	HelloService() {  
        	init_native();  
    	}  
  
    	public void setVal(int val) {  
        	setVal_native(val);  
    	}     
  
    	public int getVal() {  
        	return getVal_native();  
    	}  
      
    	private static native boolean init_native();  
        private static native void setVal_native(int val);  
    	private static native int getVal_native();  
	}


	class ServerThread extends Thread {  
    	......  
  
    	@Override  
    	public void run() {  
  
        	......  
  
        	Looper.prepare();  
  
        	......  
  
        	try {  
            	Slog.i(TAG, "Hello Service");  
            	ServiceManager.addService("hello", new HelloService());  
        	} catch (Throwable e) {  
            	Slog.e(TAG, "Failure starting Hello Service", e);  
        	}  
  
        	......  
  
        	Looper.loop();  
  
        	......  
    	}  
	}  
  
	......  
  
	public class SystemServer  
	{  
    	......  
  
    	/** 
    	* This method is called from Zygote to initialize the system. This will cause the native 
    	* services (SurfaceFlinger, AudioFlinger, etc..) to be started. After that it will call back 
    	* up into init2() to start the Android services. 
    	*/  
    	native public static void init1(String[] args);  
  
    	......  
  
    	public static final void init2() {  
        	Slog.i(TAG, "Entered the Android system server!");  
        	Thread thr = new ServerThread();  
        	thr.setName("android.server.ServerThread");  
        	thr.start();  
    	}  
    	......  
	}

	这里，我们可以看到，在ServerThread.run函数中，执行了下面代码把HelloService添加到Service Manager中去。
	这里我们关注把HelloService添加到ServiceManager中去的代码：通过调用ServiceManager.addService
	把一个HelloService实例添加到Service Manager中去。

HelloService的创建过程：
	
	这个语句会调用HelloService类的构造函数，而HelloService类继承于IHelloService.Stub类，
	IHelloService.Stub类又继承了Binder类，因此，最后会调用Binder类的构造函数：
	
	public class Binder implements IBinder {  
    	......  
      
    	private int mObject;  
      
    	......  
  
  
    	public Binder() {  
        	init();  
        	......  
    	}  
  
  
    	private native final void init();  
 
    	......  
	}

	这里调用了一个JNI方法init来初始化这个Binder对象，这个JNI方法定义在frameworks/base/core/jni/android_util_Binder.cpp文件中：

	static void android_os_Binder_init(JNIEnv* env, jobject clazz)  
	{  
    	JavaBBinderHolder* jbh = new JavaBBinderHolder(env, clazz);  
    	if (jbh == NULL) {  
        	jniThrowException(env, "java/lang/OutOfMemoryError", NULL);  
        	return;  
    	}  
    	LOGV("Java Binder %p: acquiring first ref on holder %p", clazz, jbh);  
    	jbh->incStrong(clazz);  
    	env->SetIntField(clazz, gBinderOffsets.mObject, (int)jbh);  
	}

	它实际上只做了一件事情，就是创建一个JavaBBinderHolder对象jbh，然后把这个对象的地址保存在上面的Binder类的mObject成员变量中，后面我们会用到。

进入到ServiceManagerProxy.addService函数：

	class ServiceManagerProxy implements IServiceManager {  
    	public ServiceManagerProxy(IBinder remote) {  
        	mRemote = remote;  
    	}  
  
    	......  
  	
    	public void addService(String name, IBinder service)  
        	throws RemoteException {  
            	Parcel data = Parcel.obtain();  
            	Parcel reply = Parcel.obtain();  
            	data.writeInterfaceToken(IServiceManager.descriptor);  
            	data.writeString(name);  
            	data.writeStrongBinder(service);  
            	mRemote.transact(ADD_SERVICE_TRANSACTION, data, reply, 0);  
            	reply.recycle();  
            	data.recycle();  
    	}  
  
    	......  
  
    	private IBinder mRemote;  
	}

	这里的Parcel类是用Java来实现的，它跟我们前面几篇文章介绍Binder机制时提到的用C++实现的Parcel类的作用是一样的，即用来在两个进程之间传递数据。

	Parcel.writeStrongBinder函数的实现：

		public final class Parcel {  
    	......  
  
    	/** 
    	* Write an object into the parcel at the current dataPosition(), 
    	* growing dataCapacity() if needed. 
    	*/  
    	public final native void writeStrongBinder(IBinder val);  
  
    	......  
	}

	这里的writeStrongBinder函数又是一个JNI方法，它定义在frameworks/base/core/jni/android_util_Binder.cpp文件中：

	static void android_os_Parcel_writeStrongBinder(JNIEnv* env, jobject clazz, jobject object)  
	{  
    	Parcel* parcel = parcelForJavaObject(env, clazz);  
    	if (parcel != NULL) {  
        	const status_t err = parcel->writeStrongBinder(ibinderForJavaObject(env, object));  
        	if (err != NO_ERROR) {  
            	jniThrowException(env, "java/lang/OutOfMemoryError", NULL);  
        	}  
    	}  
	} 

	 这里的clazz参数是一个Java语言实现的Parcel对象，通过parcelForJavaObject把它转换成C++语言实现的Parcel对象。

	这里的object参数是一个Java语言实现的Binder对象，在调用C++语言实现的Parcel::writeStrongBinder把这个对象写入到parcel对象时，
	首先通过ibinderForJavaObject函数把这个Java语言实现的Binder对象转换为C++语言实现的JavaBBinderHolder对象：

	sp<IBinder> ibinderForJavaObject(JNIEnv* env, jobject obj)  
	{  
    	if (obj == NULL) return NULL;  
  
    	if (env->IsInstanceOf(obj, gBinderOffsets.mClass)) {  
        	JavaBBinderHolder* jbh = (JavaBBinderHolder*)  
            	env->GetIntField(obj, gBinderOffsets.mObject);  
        	return jbh != NULL ? jbh->get(env) : NULL;  
    	}  
  
    	if (env->IsInstanceOf(obj, gBinderProxyOffsets.mClass)) {  
        	return (IBinder*)  
            	env->GetIntField(obj, gBinderProxyOffsets.mObject);  
    	}  
  
    	LOGW("ibinderForJavaObject: %p is not a Binder object", obj);  
    	return NULL;  
	} 

	我们知道，这里的obj参数是一个Binder类的实例，因此，这里会进入到第一个if语句中去。

    在前面创建HelloService对象，曾经在调用到HelloService的父类Binder中，曾经在JNI层创建了一个JavaBBinderHolder对象，
	然后把这个对象的地址保存在Binder类的mObject成员变量中，因此，这里把obj对象的mObject成员变量强制转为JavaBBinderHolder对象。

jbh != NULL ? jbh->get(env) : NULL;  

	 在JavaBBinderHolder类中，有一个成员变量mBinder，它的类型为JavaBBinder，而JavaBBinder类继承于BBinder类。

JavaBBinderHolder::get函数的实现：

	class JavaBBinderHolder : public RefBase  
	{  
    	......  
  
    	JavaBBinderHolder(JNIEnv* env, jobject object)  
        	: mObject(object)  
    	{  
        	......  
    	}  
  
    	......  
  
    	sp<JavaBBinder> get(JNIEnv* env)  
    	{  
        	AutoMutex _l(mLock);  
        	sp<JavaBBinder> b = mBinder.promote();  
        	if (b == NULL) {  
            	b = new JavaBBinder(env, mObject);  
            	mBinder = b;  
            	......  
        	}  
  
        	return b;  
    	}  
  
    	......  
  
    	jobject         mObject;  
    	wp<JavaBBinder> mBinder;  
	};

	这里是第一次调用get函数，因此，会创建一个JavaBBinder对象，并且保存在mBinder成员变量中。注意，这里的mObject就是上面创建的HelloService对象了，
	这是一个Java对象。这个HelloService对象最终也会保存在JavaBBinder对象的成员变量mObject中。

	const status_t err = parcel->writeStrongBinder(ibinderForJavaObject(env, object));  相当于：
	
	const status_t err = parcel->writeStrongBinder((JavaBBinderHodler*)(obj.mObject));  
	因此，这里的效果相当于是写入了一个JavaBBinder类型的Binder实体到parcel中去。这与我们前面介绍的Binder机制的C++实现是一致的。
    接着，再回到ServiceManagerProxy.addService这个函数中，最后它通过其成员变量mRemote来执行进程间通信操作。前面我们在介绍如何获取
	ServiceManager远程接口时提到，这里的mRemote成员变量实际上是一个BinderProxy对象。

BinderProxy.transact函数的实现：

	final class BinderProxy implements IBinder {  
    	......  
  
    	public native boolean transact(int code, Parcel data, Parcel reply,  
                                int flags) throws RemoteException;  
  
    	......  
	}

	这里的transact成员函数又是一个JNI方法，它定义在frameworks/base/core/jni/android_util_Binder.cpp文件中：

	static jboolean android_os_BinderProxy_transact(JNIEnv* env, jobject obj,  
                        jint code, jobject dataObj,  
                        jobject replyObj, jint flags)  
	{  
    	......  
  
    	Parcel* data = parcelForJavaObject(env, dataObj);  
    	if (data == NULL) {  
        	return JNI_FALSE;  
    	}  
    	Parcel* reply = parcelForJavaObject(env, replyObj);  
    	if (reply == NULL && replyObj != NULL) {  
        	return JNI_FALSE;  
    	}  
  
    	IBinder* target = (IBinder*)  
        	env->GetIntField(obj, gBinderProxyOffsets.mObject);  
    	if (target == NULL) {  
        	jniThrowException(env, "java/lang/IllegalStateException", "Binder has been finalized!");  
        	return JNI_FALSE;  
    	}  
  
    	......  
  	
    	status_t err = target->transact(code, *data, reply, flags);  
  
    	......  
  
    	if (err == NO_ERROR) {  
        	return JNI_TRUE;  
    	} else if (err == UNKNOWN_TRANSACTION) {  
        	return JNI_FALSE;  
    	}  
  
    	signalExceptionForError(env, obj, err);  
    	return JNI_FALSE;  
	}  


	这里传进来的参数dataObj和replyObj是一个Java接口实现的Parcel类，由于这里是JNI层，需要把它转换为C++实现的Parcel类，
	它们就是通过我们前面说的parcelForJavaObject函数进行转换的。前面我们在分析如何获取Service Manager远程接口时，曾经说到，在JNI层中，
	创建了一个BpBinder对象，它的句柄值为0，它的地址保存在gBinderProxyOffsets.mObject中。

	通过下面语句得到这个BpBinder对象的IBinder接口：
		IBinder* target = (IBinder*)  
        env->GetIntField(obj, gBinderProxyOffsets.mObject);  

	有了这个IBinder接口后，就和我们前面几篇文章介绍Binder机制的C/C++实现一致了。

    最后，通过BpBinder::transact函数进入到Binder驱动程序，然后Binder驱动程序唤醒Service Manager响应这个ADD_SERVICE_TRANSACTION请求：

status_t err = target->transact(code, *data, reply, flags); 

	需要注意的是，这里的data包含了一个JavaBBinderHolder类型的Binder实体对象，它就代表了我们上面创建的HelloService。
	ServiceManager收到这个ADD_SERVICE_TRANSACTION请求时，就会把这个Binder实体纳入到自己内部进行管理。这样，实现HelloService的Server的启动过程就完成了。

#####Client获取HelloService的Java远程接口的过程：

	IServiceManager.getService函数来获得HelloService的远程接口：

		class ServiceManagerProxy implements IServiceManager {  
    	public ServiceManagerProxy(IBinder remote) {  
        	mRemote = remote;  
    	}  
  
    	......  
  
    	public IBinder getService(String name) throws RemoteException {  
        	Parcel data = Parcel.obtain();  
        	Parcel reply = Parcel.obtain();  
        	data.writeInterfaceToken(IServiceManager.descriptor);  
        	data.writeString(name);  
        	mRemote.transact(GET_SERVICE_TRANSACTION, data, reply, 0);  
        	IBinder binder = reply.readStrongBinder();  
        	reply.recycle();  
        	data.recycle();  
        	return binder;  
    	}  
  
    	......  
  
    	private IBinder mRemote;  
	}

	最终通过mRemote.transact来执行实际操作。我们在前面已经介绍过了，这里的mRemote实际上是一个BinderProxy对象，
	它的transact成员函数是一个JNI方法，实现在frameworks/base/core/jni/android_util_Binder.cpp文件中的android_os_BinderProxy_transact函数中。

	这个函数前面我们已经看到了，这里就不再列出来了。不过，当这个函数从：
		status_t err = target->transact(code, *data, reply, flags);  

	 这里的reply变量里面就包括了一个HelloService的引用了。注意，这里的reply变量就是我们在ServiceManagerProxy.getService函数里面传进来的参数reply，
	它是一个Parcel对象。

mRemote.transact(GET_SERVICE_TRANSACTION, data, reply, 0);  

	接着，就通过下面语句将这个HelloService的引用读出来：
	IBinder binder = reply.readStrongBinder();  

	Parcel.readStrongBinder的实现：

		public final class Parcel {  
    		......  
  
    		/** 
    		* Read an object from the parcel at the current dataPosition(). 
    		*/  
    		public final native IBinder readStrongBinder();  
  
    		......  
	} 

	它也是一个JNI方法，实现在frameworks/base/core/jni/android_util_Binder.cpp文件中：

	static jobject android_os_Parcel_readStrongBinder(JNIEnv* env, jobject clazz)  
	{  
    	Parcel* parcel = parcelForJavaObject(env, clazz);  
    	if (parcel != NULL) {  
        	return javaObjectForIBinder(env, parcel->readStrongBinder());  
    	}  
    	return NULL;  
	}

	这里首先把Java语言实现的Parcel对象class转换成C++语言实现的Parcel对象parcel，接着，通过parcel->readStrongBinder函数来获得一个Binder引用。

	return javaObjectForIBinder(env, parcel->readStrongBinder()); 相当于：
	
	return javaObjectForIBinder(env, new BpBinder(handle)); 

	这里的handle就是HelloService这个Binder实体在Client进程中的句柄了，它是由Binder驱动程序设置的，上层不用关心它的值具体是多少。
	至于javaObjectForIBinder这个函数，我们前面介绍如何获取Service Manager的Java远程接口时已经有详细介绍，这里就不累述了，
	它的作用就是创建一个BinderProxy对象，并且把刚才获得的BpBinder对象的地址保存在这个BinderProxy对象的mObject成员变量中。

	helloService = IHelloService.Stub.asInterface(ServiceManager.getService("hello"));相当于：
	
	helloService = IHelloService.Stub.asInterface(new BinderProxy()));

	
IHelloService.Stub.asInterface是这样定义的：

	
	public interface IHelloService extends android.os.IInterface  
	{  
    	/** Local-side IPC implementation stub class. */  
    	public static abstract class Stub extends android.os.Binder implements android.os.IHelloService  
    	{  
        	......  
  
        	public static android.os.IHelloService asInterface(android.os.IBinder obj)  
        	{  
            	if ((obj==null)) {  
                	return null;  
            	}  
            	android.os.IInterface iin = (android.os.IInterface)obj.queryLocalInterface(DESCRIPTOR);  
            	if (((iin!=null)&&(iin instanceof android.os.IHelloService))) {  
                	return ((android.os.IHelloService)iin);  
            	}  
            	return new android.os.IHelloService.Stub.Proxy(obj);  
        	}  
  
        	......  
    	}  
	}

	这里的obj是一个BinderProxy对象，它的queryLocalInterface返回null，于是调用下面语句获得HelloService的远程接口：

	return new android.os.IHelloService.Stub.Proxy(obj);相当于：

	return new android.os.IHelloService.Stub.Proxy(new BinderProxy());  

	这样，我们就获得了HelloService的远程接口了，它实质上是一个实现了IHelloService接口的IHelloService.Stub.Proxy对象。

#####Client通过HelloService的Java远程接口来使用HelloService提供的服务的过程:

	假设IHelloService(AIDL文件编译生成的class文件)定义了getVal这个方法,我们调用：helloService.getVal();

	 通知前面的分析，我们知道，这里的helloService接口实际上是一个IHelloService.Stub.Proxy对象，因此，我们进入到IHelloService.Stub.Proxy类的getVal函数中：

	public interface IHelloService extends android.os.IInterface  
	{  
    	/** Local-side IPC implementation stub class. */  
    	public static abstract class Stub extends android.os.Binder implements android.os.IHelloService  
    	{  
          
        	......  
  
        	private static class Proxy implements android.os.IHelloService  
        	{  
            	private android.os.IBinder mRemote;  
  
            	......  
  
            	public int getVal() throws android.os.RemoteException  
            	{  
                	android.os.Parcel _data = android.os.Parcel.obtain();  
                	android.os.Parcel _reply = android.os.Parcel.obtain();  
                	int _result;  
                	try {  
                    	_data.writeInterfaceToken(DESCRIPTOR);  
                    	mRemote.transact(Stub.TRANSACTION_getVal, _data, _reply, 0);  
                    	_reply.readException();  
                    	_result = _reply.readInt();  
                	}  
                	finally {  
                    	_reply.recycle();  
                    	_data.recycle();  
                	}  
                	return _result;  
            	}  
        	}  
  
        	......  
        	static final int TRANSACTION_getVal = (android.os.IBinder.FIRST_CALL_TRANSACTION + 1);  
    	}  
  
    	......  
	}

	 这里我们可以看出，实际上是通过mRemote.transact来请求HelloService执行TRANSACTION_getVal操作。这里的mRemote是一个BinderProxy对象，
	这是我们在前面获取HelloService的Java远程接口的过程中创建的。

     BinderProxy.transact函数是一个JNI方法，我们在前面已经介绍过了，这里不再累述。最过调用到Binder驱动程序，Binder驱动程序唤醒HelloService这个Server。
	前面我们在介绍HelloService的启动过程时，曾经提到，HelloService这个Server线程被唤醒之后，就会调用JavaBBinder类的onTransact函数：

	class JavaBBinder : public BBinder  
	{  
    	JavaBBinder(JNIEnv* env, jobject object)  
        	: mVM(jnienv_to_javavm(env)), mObject(env->NewGlobalRef(object))  
    	{  
        	......  
    	}  
  
    	......  
  
    	virtual status_t onTransact(  
        	uint32_t code, const Parcel& data, Parcel* reply, uint32_t flags = 0)  
    	{  
        	JNIEnv* env = javavm_to_jnienv(mVM);  
  
        	......  
  
        	jboolean res = env->CallBooleanMethod(mObject, gBinderOffsets.mExecTransact,  
            	code, (int32_t)&data, (int32_t)reply, flags);  
  
        	......  
  
        	return res != JNI_FALSE ? NO_ERROR : UNKNOWN_TRANSACTION;  
    	}  
  
    	......  
  
        	JavaVM* const   mVM;  
    	jobject const   mObject;  
	};

	前面我们在介绍HelloService的启动过程时，曾经介绍过，JavaBBinder类里面的成员变量mObject就是HelloService类的一个实例对象了。因此，这里通过语句：

	jboolean res = env->CallBooleanMethod(mObject, gBinderOffsets.mExecTransact,  
            code, (int32_t)&data, (int32_t)reply, flags);

	就调用了HelloService.execTransact函数，而HelloService.execTransact函数继承了Binder类的execTransact函数：

	public class Binder implements IBinder {  
    	......  
  
    	// Entry point from android_util_Binder.cpp's onTransact  
    	private boolean execTransact(int code, int dataObj, int replyObj, int flags) {  
        	Parcel data = Parcel.obtain(dataObj);  
        	Parcel reply = Parcel.obtain(replyObj);  
        	// theoretically, we should call transact, which will call onTransact,  
        	// but all that does is rewind it, and we just got these from an IPC,  
        	// so we'll just call it directly.  
        	boolean res;  
        	try {  
            	res = onTransact(code, data, reply, flags);  
        	} catch (RemoteException e) {  
            	reply.writeException(e);  
            	res = true;  
        	} catch (RuntimeException e) {  
            	reply.writeException(e);  
            	res = true;  
        	} catch (OutOfMemoryError e) {  
            	RuntimeException re = new RuntimeException("Out of memory", e);  
            	reply.writeException(re);  
            	res = true;  
        	}	  
        	reply.recycle();  
        	data.recycle();  
        	return res;  
    	}  
	}

	这里又调用了onTransact函数来作进一步处理。由于HelloService类继承了IHelloService.Stub类，而IHelloService.Stub类实现了onTransact函数，
	HelloService类没有实现，因此，最终调用了IHelloService.Stub.onTransact函数：
 
	public interface IHelloService extends android.os.IInterface  
	{  
    	/** Local-side IPC implementation stub class. */  
    	public static abstract class Stub extends android.os.Binder implements android.os.IHelloService  
    	{  
        	......  
  
        	@Override   
        	public boolean onTransact(int code, android.os.Parcel data, android.os.Parcel reply, int flags) throws android.os.RemoteException  
        	{  
            	switch (code)  
            	{  
            	......  
            	case TRANSACTION_getVal:  
                	{  
                    	data.enforceInterface(DESCRIPTOR);  
                    	int _result = this.getVal();  
                    	reply.writeNoException();  
                    	reply.writeInt(_result);  
                    	return true;  
                	}  
            	}  
            	return super.onTransact(code, data, reply, flags);  
        	}  
  
        	......  
  
    	}  
	}  

	函数最终又调用了HelloService.getVal函数：

	public class HelloService extends IHelloService.Stub {  
    	......  
  
    	public int getVal() {  
        	return getVal_native();  
    	}  
      
    	......  
    	private static native int getVal_native();  
	}

	最终，经过层层返回，就回到IHelloService.Stub.Proxy.getVal函数中来了，从下面语句返回：

	mRemote.transact(Stub.TRANSACTION_getVal, _data, _reply, 0); 

	并将结果读出来：

	_result = _reply.readInt();  

	最后将这个结果返回到Hello.onClick函数中。这样，Client通过HelloService的Java远程接口来使用HelloService提供的服务的过程就介绍完了。