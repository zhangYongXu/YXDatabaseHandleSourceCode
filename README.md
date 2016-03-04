# YXDatabaseHandleSourceCode
这是一个基于fmdb的sqlite数据库操作封装的源码，使用它之后你将不再需要编写复杂的sql也可轻松的将oc对象保存到数据中，在查询，删除，修改时也不需要编写SQL语句，都基于类，对象进行操作，简单易用

开发iOS应用时，缓存或本地化存数据用sqlite数据库是比较好的选择，虽然fmdb库已经把c接口的方法包装成了oc代码，操作已经很好了，但是数据库中是用表存储一条条的数据，而iOS中操作的是对象，在增删改查时不得不面对为每个所要存储数据的模型类进行编写对应的sql语句，用起来一点也不简单愉快。如果能做到在增删改查时直接操作模型对象，也不用拼接sql语句，是不是在用sqlite时就跟简单、更优雅了，下面是我处理的方法。
	通过分析可以看到，模型类和数据库表是可以一一对应起来，模型类名和数据库表名对应，模型类属性名和数据库字段名一一对应，而数据类型也大致一样，常用的数据类型无非是数字型、字符串型等。所以如果引入一个规则就是模型类名作为表名，属性名作为字段名，这样就可以利用iOS的runtime机制，把操作数据库的相关sql拼接统一起来，封装起来就可以去掉重复的sql语句的拼接以及数据库数据和模型类的互转了。
	基本实现思路：
	方式一：
	用模型类和数据表对应的方式。
	1，如何拼接建表sql语句。根据模型类得到类名，利用runtime得到模型类所有的属性名称和类型。类名做表名，属性名做字段名， 根据类型拼接sql语句，就可以达到，不管设么模型类，只要传一个类就可以创建好表。
	2，如何拼接插入sql语句。根据模型对象，同样得到类名，属性名，以及属性值，就可以拼接好插入语句了，所以不管什么模型对象，就可以统一一个方法进行插入操作。
	3，如何拼接更新sql语句。更新某个对象首先从数据库查出已有数据，修改其中值，和拼接插入语句一样。
	4，如何拼接查询和删除sql语句。同上类似。

	方式二：
	用一个映射文件去关联模型类和数据表直间的对应关系。如何这个模型类对应的表名、字段名等。
	拼接sql语句时和方式一略有不同，在获取到到类名后根据类名找到对应的映射文件。在映射文件查找对应的表名和字段名等信息。再拼接sql语句。

	实现代码：
用一个单例类YXDatabaseHandle统一处理sqlite数据库相关的操作。

提供方法：
第一步：初始化数据库操作单例类。创建数据库，创建表等操作。
	//获取单例
	+(YXDatabaseHandle*)shareInstance;
   //打开数据库
	-(BOOL)openDatabaseWithPath:(NSString*)path Error:(NSError **)error;
   //关闭数据库
-(void)closeDatabase;
//注册要向数据库存数据的模型类，这时会获取模型类与表之间的关系，在tablesDict中存储这信息，并且检查如果没有建表就创建表，选择映射方式，如上所述两种方式。
-(void)registerClass:(Class)aclass MappingTypeType:(TableFeildMappingType)mappingType;
//注册要向数据库存数据的模型类，并可以设置那些字段是唯一性的
-(void)registerClass:(Class)aclass MappingTypeType:(TableFeildMappingType)mappingType UniqueColumnNameArray:(NSArray*)uniqueColumnNameArray;
第二步：增删改查，四种操作分别放在四个类别中。
插入：
//传入模型对象，保存到对应表中
-(void)insertModel:(id)model;
-(void)insertModelArray:(NSArray*)modelArray;
删除：
-(void)deleteModel:(id)model;
//根据唯一性字段删除某一个模型实体记录
-(void)deleteModel:(id)model primarykeyName:(NSString*)primarykeyName;
//根据条件删除某个模型数据
-(void)deleteClass:(Class)aclass whereArray:(NSArray*)whereArray;
更新：
//根据唯一列更新某个模型
-(void)updateModel:(id)model primarykeyName:(NSString*)primarykeyName;
//根据条件更新模型
-(void)updateModel:(id)model whereArray:(NSArray*)whereArray;
查询：
//读取某个类的所有模型数据
-(NSArray*)readArray:(Class)aclass;
//根据条件读取某个类的模型数据
-(NSArray*)readyArray:(Class)aclass whereArray:(NSArray*)whereArray;
//分页读取某个类的模型数据
-(NSArray*)readArrayClass:(Class)aclass Page:(NSInteger)page pageSize:(NSInteger)size;
//按条件分页读取某个模型的数据
-(NSArray*)readArrayClass:(Class)aclass Page:(NSInteger)page pageSize:(NSInteger)size whereArray:(NSArray*)whereArray;
//读取某个模型的数据 并排序
-(NSArray*)readArray:(Class)aclass OrderBy:(NSString*)orderBy OrderType:(OrderType)orderType;
//按条件读取某个模型的数据 并排序
-(NSArray*)readArray:(Class)aclass OrderBy:(NSString*)orderBy OrderType:(OrderType)orderType whereArray:(NSArray*)whereArray;
//根据sql读数据
-(NSArray*)readArrayBySql:(NSString*)sql;
