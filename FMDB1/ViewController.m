//
//  ViewController.m
//  FMDB1
//
//  Created by CHENSHANGMAC on 16/10/20.
//  Copyright © 2016年 CHENSHANGMAC. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
#import "NextViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     FMDatabbse对象就代表一个单独的SQLite数据库，用来执行SQL语句
     FMResultSet代表使用FMDatabase执行查询后的结果集
     FMDatabaseQueue用于在多线程中执行多个查询或更新，它是线程安全的
     
    */
    
    /*
     创建路径:三种方式
           文件路径。该文件路径无需真实存在，如果不存在会自动创建
           空字符串(@“”)。表示会在临时目录创建一个空的数据库，当FMDatabase连接关闭时，文件也会被删除
           NULL。将创建一个内在数据库，同样的，当FMDatabase连接关闭时，数据将会被销毁
     */
    
    //获取数据库文件的路径
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [doc stringByAppendingPathComponent:@"student.sqlite"];
    
    NSLog(@"表路径%@",fileName);
    //创建数据库
    FMDatabase *database = [FMDatabase databaseWithPath:fileName];
    //操作FMDatabase数据库时，必须先打开，如果打开失败，可能是权限不足或者资源不足，操作完成之后需要调用close方法来关闭数据库
    if ([database open])
    {
        //创建一个表
        BOOL result = [database executeUpdate:@"CREATE TABLE IF NOT EXISTS student (id integer INTEGER PRIMARY KEY ,name text NOT NULL,age integer NOT NULL);"];
        if (result)
        {
            NSLog(@"创建表成功");
        }
    }
    /*除了SELECT命令之外的操作都视为更新
          包括:CREAT,UPDATE,INSERT,ALTER，BEGIN,COMMIT,DETACH,DELETE,DROP,END,EXPLAIN,VACUUM,REPLACE等；
          更新操作返回一个BOOL值，返回NO表示有错误，可以调用lastErrorMessage和-lastErrorCode方法来得到更多信息
     
     */
    
    //插入命令   executeUpdate + insert into    ？表示占位符，参数必须为OC对象 ;代表语句结束
    [database executeUpdate:@"INSERT INTO student (name,age) VALUES (?,?);",@"张三",@(18) ];
    //插入命令  executeUpdateWithForamat: 不确定的参数用%@方式占位
    [database executeUpdateWithFormat:@"insert into student (name,age) values (%@,%i);",@"李四",19];
    //插入命令  使用数组参数
    [database executeUpdate:@"INSERT INTO student(name,age) VALUES (?,?);" withArgumentsInArray:@[@"王五",@"20"]];
    [database executeUpdate:@"INSERT INTO student(name,age) VALUES (?,?);" withArgumentsInArray:@[@"赵六",@"21"]];
    
    
    //删除命令 未知参数用？占位  对应的参数必须是OC对象  如果有int类型需要转换
    [database executeUpdate:@"delete from student where id = ?;",@(18)];
    //删除命令 未知的参数用%@等来占位
    [database executeUpdateWithFormat:@"delete from student where name = %@;",@"李四"];
    
    
    //修改命令 将赵六的名字改为赵子龙
    [database executeUpdate:@"update student set name = ? where name = ?",@"赵子龙",@"赵六"];
    
    //查询命令 select ... from
    /*
     SELECT命令就是查询，执行查询的方法是以excuteQuery开头的
     执行查询操作，如果查询成功返回FMResultSet对象，错误返回nil.与更新操作类似，支持NSError参数
     也可以使用lastErrorCode和lastErrorMessage获取错误信息
    */
    /*
     FMResultSet获取不同数据格式:
              intForColumn:
              longForColumn:
              longLongintForColumn:
              boolForColumn:
              doubleForColumn:
              stringForColumn:
              dataForColumn:
              dataNoCopyForColumn:
              UTF8StringForColumnindex:
              objectForColumn:
     */
    //查询表
    FMResultSet *resultSet = [database executeQuery:@"select *from student;"];
    //条件查询
    //FMResultSet *resultWhere = [database executeQuery:@"select *from student where id<?;",@(3)];
    //查看查询结果
    while ([resultSet next])
    {
        int  count = [resultSet intForColumn:@"id"];
        NSString *name = [resultSet stringForColumn:@"name"];
        int age = [resultSet intForColumn:@"age"];
        
        NSLog(@"编号:%d,姓名:%@,年龄:%d",count,name,age);
    }
    //销毁命令  如果表格存在 则销毁
    [database executeUpdate:@"drop table if exists student;"];
    
    
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom ];
    button.backgroundColor = [UIColor lightGrayColor];
    [button setTitle:@"next" forState:UIControlStateNormal];
    button.frame = CGRectMake( ([UIScreen mainScreen].bounds.size.width - 50 ) / 2.0, 200, 50, 40);
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}


-(void)buttonClick:(UIButton *)button
{
    NextViewController *next = [[NextViewController alloc] init];
    [self presentViewController:next animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
