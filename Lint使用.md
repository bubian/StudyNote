###配置

对于执行 Lint 操作的相关配置，是定义在 gradle 文件的 lintOptions 中，可定义的选项及其默认值包括

    android { <br/>
    	lintOptions {
    		// 设置为 true，则当 Lint 发现错误时停止 Gradle 构建
    		abortOnError false 
    		// 设置为 true，则当有错误时会显示文件的全路径或绝对路径 (默认情况下为true)
    		absolutePaths true 
    		// 仅检查指定的问题（根据 id 指定）
    		check 'NewApi', 'InlinedApi'
    		// 设置为 true 则检查所有的问题，包括默认不检查问题 
    		checkAllWarnings true 
    		// 设置为 true 后，release 构建都会以 Fatal 的设置来运行 Lint。
    		// 如果构建时发现了致命（Fatal）的问题，会中止构建（具体由 abortOnError 控制）
    		checkReleaseBuilds true 
    		// 不检查指定的问题（根据问题 id 指定）
    		disable 'TypographyFractions','TypographyQuotes'
    		// 检查指定的问题（根据 id 指定） <br/>
    		enable 'RtlHardcoded','RtlCompat', 'RtlEnabled' 
    		// 在报告中是否返回对应的 Lint 说明 
    		explainIssues true 
    		// 写入报告的路径，默认为构建目录下的 lint-results.html 
    		htmlOutput file("lint-report.html") 
    		// 设置为 true 则会生成一个 HTML 格式的报告 
    		htmlReport true 
    		// 设置为 true 则只报告错误 
    		ignoreWarnings true 
    		// 重新指定 Lint 规则配置文件 
    		lintConfig file("default-lint.xml") 
    		// 设置为 true 则错误报告中不包括源代码的行号 
    		noLines true 
    		// 设置为 true 时 Lint 将不报告分析的进度 
    		quiet true 
    		// 覆盖 Lint 规则的严重程度，例如： 
    		severityOverrides ["MissingTranslation": LintOptions.SEVERITY_WARNING] 
    		// 设置为 true 则显示一个问题所在的所有地方，而不会截短列表 
    		showAll true 
    		// 配置写入输出结果的位置，格式可以是文件或 stdout 
    		textOutput 'stdout' 
    		// 设置为 true，则生成纯文本报告（默认为 false）
    		textReport false 
    		// 设置为 true，则会把所有警告视为错误处理 
    		warningsAsErrors true 
    		// 写入检查报告的文件（不指定默认为 lint-results.xml）
    		xmlOutput file("lint-report.xml") 
    		// 设置为 true 则会生成一个 XML 报告 
    		xmlReport false 
    		// 将指定问题（根据 id 指定）的严重级别（severity）设置为 Fatal 
    		fatal 'NewApi', 'InlineApi'
    		// 将指定问题（根据 id 指定）的严重级别（severity）设置为 Error 
    		error 'Wakelock', 'TextViewEdits' 
    		// 将指定问题（根据 id 指定）的严重级别（severity）设置为 Warning 
    		warning 'ResourceAsColor' 
    		// 将指定问题（根据 id 指定）的严重级别（severity）设置为 ignore 
    		ignore 'TypographyQuotes' 
    	} <br/>
    }


###lint.xml 

    这个文件则是配置 Lint 需要禁用哪些规则（issue），以及自定义规则的严重程度（severity），lint.xml 文件是通过 issue 标签指定对一个规则的控制，
	在项目根目录中建立一个 lint.xml 文件后 Android Lint 会自动识别该文件，在执行检查时按照 lint.xml 的内容进行检查。如上面提到的那样，开发者也可以通过 lintOptions 
    中的 lintConfig 选项来指定配置文件。一个 lint.xml 示例如下：

    <?xml version="1.0" encoding="UTF-8"?> >
    <lint> 
    	<!-- Disable the given check in this project --> 
    	<issue id="HardcodedText" severity="ignore"/> 
    	<issue id="SmallSp" severity="ignore"/> 
    	<issue id="IconMissingDensityFolder" severity="ignore"/>
    	<issue id="RtlHardcoded" severity="ignore"/> 
    	<issue id="Deprecated" severity="warning"> 
    	<ignore regexp="singleLine"/> 
    	</issue> 
    </lint>

    issue 标签中使用 id 指定一个规则，severity="ignore" 则表明禁用这个规则。需要注意的是，某些规则可以通过 ignore 标签指定仅对某些属性禁用，例如上面的 Deprecated，表示检查是否有使用不推荐的属性和方法，而在 issue 标签中包裹一个 ignore 标签，在 ignore 标签的 regexp 属性中使用正则表达式指定了 singleLine，则表明对 singleLine 这个属性屏蔽检查。
    
    另外开发者也可以使用 @SuppressLint(issue id) 标注针对某些代码忽略某些 Lint 检查，这个标注既可以加到成员变量之前，也可以加到方法声明和类声明之前，分别针对不同范围进行屏蔽。

###f分类

    如上图所展示的，Android Lint 对检查的结果进行了分类，同一个规则（issue）下的问题会聚合，其中针对 Android 的规则类别会在分类前说明是 Android 相关的，主要是六类`：

    Accessibility 无障碍，例如 ImageView 缺少 contentDescription 描述，String 编码字符串等问题。 <br/>
    Correctness 正确性，例如 xml 中使用了不正确的属性值，Java 代码中直接使用了超过最低 SDK 要求的 API 等。 <br/>
    Internationalization 国际化，如字符缺少翻译等问题。 <br/>
    Performance 性能，例如在 onMeasure、onDraw 中执行 new，内存泄露，产生了冗余的资源，xml 结构冗余等。
    Security 安全性，例如没有使用 HTTPS 连接 Gradle，AndroidManifest 中的权限问题等。
    Usability 易用性，例如缺少某些倍数的切图，重复图标等。
    其他的结果条目则是针对 Java 语法的问题，另外每一个问题都有区分严重程度（severity），从高到底依次是：

    Fatal
    Error
    Warning
    Information
    Ignore
