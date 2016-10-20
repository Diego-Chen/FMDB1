//
//  NextViewController.m
//  FMDB1
//
//  Created by CHENSHANGMAC on 16/10/20.
//  Copyright © 2016年 CHENSHANGMAC. All rights reserved.
//

#import "NextViewController.h"
#import "FMDB.h"

@interface NextViewController ()

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    /*
     sqlite数据库是iOS开发中经常使用到的数据持久化方案
     
    
     其实FMDB本身已经对多线程做了考虑，FMDatabaseQueue就是为了解决数据库操作线程安全的,只是由于之前框架集成的单例操作，并且没有设计多线程访问，所以并没有发生这个问题。
     FMDatabaseQueue解决线程安全的操作方法 等于是把数据库的操作放到一个串行队列中，从而保证不会在同一时间对数据库做改动。
     
     
     */
    
    
    
    
    
    
    
    
    
    
    //在多个线程中同时使用一个FMDatabase实例是不明智的，我们可以每个线程创建一个FMDatabae对象，而不能使得多个线程分享同一个实例。如果在多个线程中同时使用一个FMDatabase实例，程序会奔溃或者报告异常，FMDatabaseQueue就没有这种问题
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [doc stringByAppendingPathComponent:@"test.db"];
    NSLog(@"文件路径:%@",fileName);
    
    
    FMDatabase *database = [FMDatabase databaseWithPath:fileName];
    //操作FMDatabase数据库时，必须先打开，如果打开失败，可能是权限不足或者资源不足，操作完成之后需要调用close方法来关闭数据库
    if ([database open])
    {
        //创建一个表
        BOOL result = [database executeUpdate:@"CREATE TABLE IF NOT EXISTS test (name text NOT NULL,age text NOT NULL,addres text NOT NULL);"];
        if (result)
        {
            NSLog(@"创建表成功");
        }
    }
    
    
    
    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:fileName];
    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
    dispatch_queue_t q2 = dispatch_queue_create("queue2", NULL);
    
    dispatch_async(q1, ^{
       
            [queue inDatabase:^(FMDatabase *db2) {
                
                NSString *insertSql1= [NSString stringWithFormat:@"INSERT INTO test (name, age, addres) VALUES (?, ?, ?);"];
                
                NSString * name = @"李四";
                NSString * age = @"20";
                
                
                BOOL res = [db2 executeUpdate:insertSql1, name, age,@"济南"];
                if (!res)
                {
                    NSLog(@"error to inster data: %@", name);
                    
                } else
                {
                    NSLog(@"succ to inster data: %@", name);
                }
            }];
        
    });
    
    dispatch_async(q2, ^{
        for (int i = 0; i < 50; ++i) {
            [queue inDatabase:^(FMDatabase *db2) {
                NSString *insertSql2= [NSString stringWithFormat:
                                       @"INSERT INTO test ('%@', '%@', '%@') VALUES (?, ?, ?)", @"name", @"age", @"addres"];
                
                NSString * name = [NSString stringWithFormat:@"lilei %d", i];
                NSString * age = [NSString stringWithFormat:@"%d", 10+i];
                
                BOOL res = [db2 executeUpdate:insertSql2, name, age,@"北京"];
                if (!res) {
                    NSLog(@"error to inster data: %@", name);
                } else {
                    NSLog(@"succ to inster data: %@", name);
                }
            }];
        }  
    });
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 
 在iOS开发中，大家很可能会用到这样一个数据库封装：fmdb.
 该封装相比coredata来说有他自己的优势：接口清晰，设计简单，符合规范，多线程情况下使用databasequeue来进行操作也很方便，还可以在其基础上再进行一些封装来方便项目的使用。
 
 正是因为fmdb的简单性，所以很容易被误用。在我们的项目开发中就遇到了一例(我们项目中的代码进行了封装，我这里将其还原，写示例来作说明)：
 
 [queue inTransaction:^(FMDatabase *db, BOOL *rollback) 
 {
     [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:1]];
     [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:2]];
     [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:3]];
 
     [queue inDatabase:^(FMDatabase *db) {
     //  do work B
     }];
 
 
     if (whoopsSomethingWrongHappened) {
           *rollback = YES; return;
     }
     // etc…
     [db executeUpdate:@"INSERT INTO myTable VALUES (?)", [NSNumber numberWithInt:4]];
 
 }];

 在queue的事务内部又嵌套使用了该queue去执行任务b,而作为一个串行化的队列来说必须要等该事务整个执行完毕才能执行任务b；此时任务b无法走下去，该事务也就无法执行完毕，导致了死锁。
 用一个比喻来说这个问题：一个人出门把门锁上了，然后把钥匙从门缝又塞回到家里，这样他就无法再进入家门了。
从原理上讲任何串行队列里面串行任务嵌套执行都有问题。

 */

@end
