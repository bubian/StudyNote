###C++类型转换
---
####隐式转换
例如：

	int ival = 3;
	double dval = 3.14159;
	ival + dval;//ival被提升为double类型
####显示转换（即强制转换（cast））
C     风格： (type-id)   
C++风格： static_cast、dynamic_cast、reinterpret_cast、和const_cast..

    static_cast：  
	    用法：static_cast < type-id > ( expression )
        说明：该运算符把expression转换为type-id类型，但没有运行时类型检查来保证转换的安全性。
		来源：为什么需要static_cast强制转换？
		     情况1：void指针->其他类型指针
		     情况2：改变通常的标准转换
		     情况3：避免出现可能多种转换的歧义
		它主要有如下几种用法：
			 情况1:用于类层次结构中基类和子类之间指针或引用的转换。进行上行转换（把子类的指针或引用转换成基类表示）是安全的；进行下行转换（把基类指针或引用转换成子类指针或引用）时，由于没有动态类型检查，所以是不安全的。
		     情况2:用于基本数据类型之间的转换，如把int转换成char，把int转换成enum。这种转换的安全性也要开发人员来保证。
		     情况3:把void指针转换成目标类型的指针(不安全!!)
		     情况4:把任何类型的表达式转换成void类型。
		注意：static_cast不能转换掉expression的const、volitale、或者__unaligned属性。

	dynamic_cast
		用法：dynamic_cast < type-id > ( expression )
		说明：该运算符把expression转换成type-id类型的对象。Type-id必须是类的指针、类的引用或者void *；如	 果type-id是类指针类型，那么expression也必须是一个指针，如果type-id是一个引用，那么		  	 expression也必须是一个引用。
		来源：为什么需要dynamic_cast强制转换？简单的说:当无法使用virtual函数的时候.  
		注意：dynamic_cast主要用于类层次间的上行转换和下行转换，还可以用于类之间的交叉转换。
			 在类层次间进行上行转换时，dynamic_cast和static_cast的效果是一样的；在进行下行转换时，dynamic_cast具有类型检查的功能，比static_cast更安全。  

	reinpreter_cast
		用法：reinpreter_cast<type-id> (expression)
		说明：type-id必须是一个指针、引用、算术类型、函数指针或者成员指针。它可以把一个指针转换成一个整数，也可以把一个整数转换成一个指针（先把一个指针转换成一个整数，在把该整数转换成原类型的指针，还可以得到原先的指针值）。   

	const_cast
		用法：const_cast<type_id> (expression)
		说明：该运算符用来修改类型的const或volatile属性。除了const 或volatile修饰之外， type_id和	  	 expression的类型是一样的。
		常量指针被转化成非常量指针，并且仍然指向原来的对象；常量引用被转换成非常量引用，并且仍然指向原来的对象；常量对象被转换成非常量对象。