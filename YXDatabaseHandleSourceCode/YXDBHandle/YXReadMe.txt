说明：这个库是用来简化操作sqlite数据库，可以直接存储oc对象，省去了写sql语句的代码。
实现逻辑：通过oc模型和数据表之间的表明和数据字段的映射自动创建表。以及当模型属性名添加时自动添加字段。
模型和表映射方式：
    1，模型和表一一对应映射，即用模型类名作为表名称，用模型属性名作为字段名。
    2，模型和表通过映射文件映射，每一个模型对应一个映射文件，映射文件格式如：YXLogsModel_table_mappingFile.plist。在这个文件里包含了表名称，以及字段名称和类型等信息。注意，映射文件命名必须是这种格式：类名_table_mappingFile.plist
使用步骤：一般在appDelegate里初始化数据库操作类，然后注册要存储的模型
    //获取数据库操作单例
    YXDatabaseHandle * dbHandle = [YXDatabaseHandle shareInstance];
    //打开数据库
    [dbHandle openDatabase];
    //注册模型
    //这是第一种映射
    [dbHandle registerClass:[ReadLogsModel class] MappingTypeType:TableFeildMappingTypeClassProperty UniqueColumnNameArray:[NSArray arrayWithObject:@"BorrowBookBillId"]];
    //这是第二种映射
    [dbHandle registerClass:[YXLogsModel class] MappingTypeType:TableFeildMappingTypeMappingFile]
    //之后就可以进行增删改查了
其他：
    1，映射文件结构：


@{
    "tableName":"logs",//表名称,必填
    "primaryKey":"id",//表主键,必填
    "primaryPropertyName":"logId",//主键对应模型属性的名称,非必填
    "primaryPropertyType":"NSNumber",//主键对应模型属性的类型,非必填
    "columnInfoDict":[//表的列信息,必填
        @{
            "columnName":"time",// 列名称,必填
            "columnType":"text",// 列类型,必填
            "propertyName":"logTime",//模型属性名称,必填
            "propertyType":"NSString",//模型属性类型,必填
            "propertyTypeCategory":"1",//模型属性类型,必填:{0:基本数据类型,1:结构体类型,2:对象类型}
            "isUnique":"0",//列是否有唯一性,必填
            "defaultValue":"",//列默认值,非必填
            "columnDescription":"记录时间"//列描述,非必填
        },
        @{

        }
    ]
}

问题处理：
    1，由于库中使用了类别，所以如果出现找不到方法的错误时，需要在Other Linker flags 中加入-ObjC和-all_load
    2，需要以来库sqlite







