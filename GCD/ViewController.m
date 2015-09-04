//
//  ViewController.m
//  GCD
//
//  Created by 孔凡伍 on 15/9/2.
//  Copyright (c) 2015年 kongfanwu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self createSerial];
    
//    [self createConcurrent];
    
//    [self getSystemConcurrentQueue];
    
//    [self setQueuePriority];
    
//    [self time];
    
//    [self lastBlock];
    
//    [self barrier_async];
    
//    [self dispatch_apply];
    
    [self dispatch_semaphore];
}

/**
 *  创建串行队列
 */
- (void)createSerial
{
    // 串行队列
    dispatch_queue_t mySerialQueue = dispatch_queue_create("com.dev.mySerialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(mySerialQueue, ^{
        for (int i = 0; i < 1000; i++) {
            NSLog(@"1");
        }
    });
    
    dispatch_async(mySerialQueue, ^{
        NSLog(@"2");
    });
    
    dispatch_async(mySerialQueue, ^{
       NSLog(@"3");
    });
    
    dispatch_async(mySerialQueue, ^{
       NSLog(@"4");
    });
    
}

/**
 *  获取主线程串行队列
 */
- (void)getMainQueue
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        NSLog(@"主线程中执行的");
    });
}

/**
 *  创建并行队列
 */
- (void)createConcurrent
{
    // 并行队列
    dispatch_queue_t myConcurrentQueue = dispatch_queue_create("com.dev.myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(myConcurrentQueue, ^{
        for (int i = 0; i < 1000; i++) {
            NSLog(@"1");
        }
    });
    
    dispatch_async(myConcurrentQueue, ^{
        for (int i = 0; i < 1000; i++) {
            NSLog(@"2");
        }
    });
    
    dispatch_async(myConcurrentQueue, ^{
        for (int i = 0; i < 1000; i++) {
            NSLog(@"3");
        }
    });
    
    dispatch_async(myConcurrentQueue, ^{
        for (int i = 0; i < 1000; i++) {
            NSLog(@"4");
        }
    });
}

/**
 *  获取系统提供的队列
 */
- (void)getSystemConcurrentQueue
{
    /* 优先级
     DISPATCH_QUEUE_PRIORITY_HIGH       高
     DISPATCH_QUEUE_PRIORITY_DEFAULT    默认
     DISPATCH_QUEUE_PRIORITY_LOW        低
     DISPATCH_QUEUE_PRIORITY_BACKGROUND 后台运行
     */
    dispatch_queue_t highQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t lowQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    dispatch_async(highQueue, ^{
        NSLog(@"highQueue");
    });
    
    dispatch_async(defaultQueue, ^{
        NSLog(@"defaultQueue");
    });
    
    dispatch_async(lowQueue, ^{
        NSLog(@"lowQueue");
    });
    
    dispatch_async(backgroundQueue, ^{
        NSLog(@"backgroundQueue");
    });
}

/**
 *  1 改变队列优先级
 *  2 dispatch Queue 执行层阶
 */
- (void)setQueuePriority
{
    // 1 改变队列优先级
    dispatch_queue_t queue = dispatch_queue_create("com.dev.queue", 0);
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    // queue: 要变更优先级的队列 queue2:要变更成优先级的队列
    dispatch_set_target_queue(queue, queue2);
    
    // 2 dispatch Queue 执行层阶
    dispatch_queue_t queue3 = dispatch_queue_create("com.dev.queue3", 0);
    dispatch_queue_t queue4 = dispatch_queue_create("com.dev.queue4", 0);
    dispatch_queue_t queue5 = dispatch_queue_create("com.dev.queue5", 0);
    /*
     * 将 queue4 queue5 指定目标位 queue3
     * queue3 先执行 queue4 queue5 后执行，
     * 可防止 串行队列并行执行
     */
    dispatch_set_target_queue(queue5, queue3);
    dispatch_set_target_queue(queue4, queue3);
    
    dispatch_async(queue3, ^{
        NSLog(@"queue3");
    });
    
    dispatch_async(queue5, ^{
        NSLog(@"queue5");
    });
    
    dispatch_async(queue4, ^{
        NSLog(@"queue4");
        
    });
}

/**
 *  3秒后执行
 */
- (void)time
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3ull * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"三秒后执行");
    });
}

/**
 *  多线程全部执行完，执行最后的block
 */
- (void)lastBlock
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"1");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"2");
    });
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"3");
    });
 
    dispatch_group_notify(group, queue, ^{
        NSLog(@"最后执行");
    });
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3ull * NSEC_PER_SEC);
    /*
     * dispatch_group_wait 此线程一直等待状态
     * DISPATCH_TIME_FOREVER 直到等待全部执行结束 必返回0
     * time 超时时间 为3妙
     */
    long result = dispatch_group_wait(group, time);
    if (result == 0) {
        NSLog(@"全部处理结束");
    } else {
        NSLog(@"没有全部处理结束");
    }
}

/**
 *  避免数据竞争
 */
- (void)barrier_async
{
    dispatch_queue_t queue = dispatch_queue_create("com.dev.fanwu", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{ NSLog(@"1"); });
    dispatch_async(queue, ^{ NSLog(@"2"); });
    dispatch_async(queue, ^{ NSLog(@"3"); });
    // 与并行对列使用。先等待queue中得线程全部执行完毕，在执行 dispatch_barrier_sync。dispatch_barrier_sync执行完回复 queue状态继续执行剩余的线程
    dispatch_barrier_sync(queue, ^{
        NSLog(@"中间插入数据");
    });
    dispatch_async(queue, ^{ NSLog(@"4"); });
    dispatch_async(queue, ^{ NSLog(@"5"); });
    dispatch_async(queue, ^{ NSLog(@"6"); });
   
}

/**
 *  循环N次
 */
- (void)dispatch_apply
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    /*
     * 并行执行 非顺序执行(0 1 2)。
     * dispatch_apply 会等待全部处理结束，最后打印 "done"
     */
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"index:%ld",index);
    });
    NSLog(@"done");
}

/**
 *  queue 挂起 恢复
 */
- (void)queue_suspend_resume
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 挂起 对已经执行的线程没有影响，后续追加的线程且尚未执行，恢复后可继续执行
    dispatch_suspend(queue);
    // 恢复
    dispatch_resume(queue);
}

/**
 *  持有计数信号
 */
- (void)dispatch_semaphore
{
    NSMutableArray *array = [NSMutableArray array];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 初始值计数为1，保证只有一个线程访问数组
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    for (int i = 0; i < 1000; i++) {
        dispatch_async(queue, ^{
            /**
             *  等待,由于semaphore计数大于1， semaphore执行减1并返回。
             * 此时semaphore计数为0，访问数组线程只有一个，可安全更新
             */
            long result = dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (result == 0) {
                NSLog(@"插入");
                [array addObject:@(i)];

            } else {
                NSLog(@"待机");
            }
            
            /**
             *  排除其他线程控制结束，dispatch_semaphore_signal 使semaphore 计数加1
             */
            dispatch_semaphore_signal(semaphore);

        });
    }
    
    NSLog(@"%@",array);
}








@end
