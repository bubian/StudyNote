OQL���:
	�����﷨:select <JavaScript expression to select> [from [instanceof] <class name> <identifier>] [where <javascript boolean expression to filter>]
	���ͣ� 
	(1)class name��Java�����ȫ�޶������磺java.lang.String, java.util.ArrayList, [C��char����, [Ljava.io.File��java.io.File[]
	(2)�����ȫ�޶���������Ψһ�ı�ʶһ���࣬��Ϊ��ͬ��ClassLoader�������ͬ���࣬������jvm���ǲ�ͬ���͵�
	(3)instanceof��ʾҲ��ѯĳһ��������࣬�������ȷinstanceof����ֻ��ȷ��ѯclass nameָ������
	(4)from��where�Ӿ䶼�ǿ�ѡ��
	(5)java���ʾ��obj.field_name��java�����ʾ��array[index]

	������ 
	��1����ѯ���ȴ���100���ַ���
			select s from java.lang.String s where s.count > 100

	��2����ѯ���ȴ���256������
			select a from [I a where a.length > 256
	��3����ʾƥ��ĳһ������ʽ���ַ���
			select a.value.toString() from java.lang.String s where /java/(s.value.toString())
	��4����ʾ�����ļ�������ļ�·��
			select file.path.value.toString() from java.io.File file
	��5����ʾ����ClassLoader������
			select classof(cl).name from instanceof java.lang.ClassLoader cl
	��6��ͨ�����ò�ѯ����
			select o from instanceof 0xd404d404 o

	built-in���� -- heap 
		(1)heap.findClass(class name) -- �ҵ���
			select heap.findClass("java.lang.String").superclass
		(2)heap.findObject(object id) -- �ҵ�����
			select heap.findObject("0xd404d404")
		(3)heap.classes -- �������ö��
			select heap.classes
		(4)heap.objects -- ���ж����ö��
			select heap.objects("java.lang.String")
		(5)heap.finalizables -- �ȴ������ռ���java�����ö��
		(6)heap.livepaths -- ĳһ������·��
			select heaplivepaths(s) from java.lang.String s
		(7)heap.roots -- �Ѹ�����ö��

	��ʶ����ĺ��� 
		(1)classof(class name) -- ����java����������
			select classof(cl).name from instanceof java.lang.ClassLoader cl
		(2)identical(object1,object2) -- �����Ƿ�����������ͬһ��ʵ��
			select identical(heap.findClass("java.lang.String").name, heap.findClass("java.lang.String").name)
		(3)objectid(object) -- ���ض����id
			select objectid(s) from java.lang.String s
		(4)reachables -- ���ؿɴӶ���ɵ���Ķ���
			select reachables(p) from java.util.Properties p -- ��ѯ��Properties����ɵ���Ķ���
			select reachables(u, "java.NET.URL.handler") from java.Net.URL u -- ��ѯ��URL����ɵ���Ķ��󣬵���������URL.handler�ɵ���Ķ���
		(5)referrers(object) -- ��������ĳһ����Ķ���
			select referrers(s) from java.lang.String s where s.count > 100
		(6)referees(object) -- ����ĳһ�������õĶ���
			select referees(s) from java.lang.String s where s.count > 100
		(7)refers(object1,object2) -- �����Ƿ��һ���������õڶ�������
			select refers(heap.findObject("0xd4d4d4d4"),heap.findObject("0xe4e4e4e4"))
		(8)root(object) -- �����Ƿ�����Ǹ����ĳ�Ա
			select root(heap.findObject("0xd4d4d4d4")) 
		(9)sizeof(object) -- ���ض���Ĵ�С
			select sizeof(o) from [I o
		(10)toHtml(object) -- ���ض����html��ʽ
			select "<b>" + toHtml(o) + "</b>" from java.lang.Object o
		(11)ѡ���ֵ
			select {name:t.name?t.name.toString():"null",thread:t} from instanceof java.lang.Thread t

	���顢�������Ⱥ��� 
		(1)concat(enumeration1,enumeration2) -- �������ö�ٽ�������
			select concat(referrers(p),referrers(p)) from java.util.Properties p
		(2)contains(array, expression) -- ������Ԫ���Ƿ�����ĳ���ʽ
			select p from java.util.Properties where contains(referres(p), "classof(it).name == 'java.lang.Class'")
			������java.lang.Class���õ�java.util.Properties����
		built-in����
			it -- ��ǰ�ĵ���Ԫ��
			index -- ��ǰ����Ԫ�ص�����
			array -- ������������
		(3)count(array, expression) -- ����ĳһ������Ԫ�ص�����
			select count(heap.classes(), "/java.io./(it.name)")
		(4)filter(array, expression) -- ���˳�����ĳһ������Ԫ��
			select filter(heap.classes(), "/java.io./(it.name)")
		(5)length(array) -- �������鳤��
			select length(heap.classes())
		(6)map(array,expression) -- ���ݱ��ʽ�������е�Ԫ�ؽ���ת��ӳ��
			select map(heap.classes(),"index + '-->' + toHtml(it)")
		(7)max(array,expression) -- ���ֵ, min(array,expression)
			select max(heap.objects("java.lang.String"),"lhs.count>rhs.count")
			built-in����
			lhs -- ���Ԫ��
			rhs -- �ұ�Ԫ��
		(8)sort(array,expression) -- ����
			select sort(heap.objects('[C'),'sizeof(lhs)-sizeof(rhs)')
		(9)sum(array,expression) -- ���
			select sum(heap.objects('[C'),'sizeof(it)')
		(10)toArray(array) -- ��������
		(11)unique(array) -- Ψһ������

 