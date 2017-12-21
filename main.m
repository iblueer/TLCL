//
//  main.m
//  mdAppending
//
//  Created by 宅音かがや on 2017/12/22.
//  Copyright © 2017年 宅音かがや. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool{
        
        NSString *folder = @"/Users/Shared/book";
        NSString *fileTLCL = @"/Users/Shared/book/TLCL.md";
        
        // 首先创建一个文件管理器，让它检测到目标目录。
        NSFileManager *fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:folder]) {
            // 如果没检测到book目录就报警。
            NSLog(@"error: no directory found.");
        }
        
        // 然后创建一个NSString对象，将文本读取进来，作为NSString对象的内容。
        NSMutableString *content = [[NSMutableString alloc] init];
        [content appendString:@"# 《快乐的 Linux 命令行》\n\nhttp://billie66.github.com/TLCL"];
        
        // 遍历book目录，删掉不需要的内容
        NSArray *array=[fm contentsOfDirectoryAtPath:folder error:nil];
        
        for(NSString *p in array) {
            NSLog(@"文件名：%@",p);
            if(![p containsString:@".md"]) {
                // 获得这个文件的路径
                NSString *rmfile = [NSString stringWithFormat:@"/Users/Shared/book/%@", p];
                // 删除这个文件
                [fm removeItemAtPath:rmfile error:nil];
                NSLog(@"removed %@", p);
            }
        }
        
        // 释放掉旧的array，建立一个新的array
        array = nil;
        array = [fm contentsOfDirectoryAtPath:folder error:nil];
        // 输出现在Array里面一共多少文件
        NSLog(@"Array中一共有%ld文件", [array count]);
        
        // 对Array进行排序，或许需要建立一个MutableArray。我不知道怎么对字符串排序。
        //1.对数组进行升序排序
        NSLog(@"数组排序到新数组");
        //sortedArrayUsingSelector排序适用于升序以及自定义的排序场景.
        NSArray *sortArrAscending = [array sortedArrayUsingSelector:@selector(compare:)];
        for(NSString *p in sortArrAscending) {
            NSLog(@"文件名：%@",p);
        }
        // 排序成功
        
        //然后依次读取文本文件的内容，每次读取之后要进行查找和替换，替换后加到text对象中。
        // 我不知道content能不能装得下这么多内容。
        for(NSString *p in sortArrAscending) {
            NSLog(@"文件名：%@",p);
            // 获得这个文件的路径
            NSString *getFile = [NSString stringWithFormat:@"/Users/Shared/book/%@", p];
            // 得到这个文件的内容
            NSString *strHTML=[NSString stringWithContentsOfFile:getFile encoding:NSUTF8StringEncoding error:nil];
            // 对这个文件进行过滤，查找对应的文字串，并将其改变为另外的文字串。
            {
                // 正序查找
                NSString *keywordBegin = @"title: ";
                NSString *keywordEnd = @"\n---";
                NSRange rangeTitle = [strHTML rangeOfString:keywordBegin];//声明枚举类型的实例对象不用加 * ，如果加了 * ，就成这个对象的地址了，显然就不对了。
                NSRange rangeDash = [strHTML rangeOfString:keywordEnd];
                //创建两个整形，保存子字符串的位置
                NSUInteger start = 0;
                NSUInteger end = 0;
                if ((rangeTitle.location!=NSNotFound)&&(rangeDash.location!=NSNotFound)&&(rangeTitle.location < rangeDash.location)) {//这里其实就是如果 子字符串 在 该字符串 中的位置不是无限大，那么肯定就对了，如果无限大，肯定就跑到外面去了，就找不到了～
                    NSLog(@"%@ 查找成功", p);
                    start = rangeTitle.location + rangeTitle.length;
                    end = rangeDash.location;
                    // 输出他的起止位置
                    NSLog(@"start = %ld, end = %ld", start, end);
                    // 然后就是获得这一篇的题目
                    // 将子字符串的位置保存为一个NSRange类型
                    NSUInteger length = end - start;
                    NSRange stringRange = {start, length};
                    // start表示的是提取的初始位置.
                    // length表示的是提取字符的长度.
                    // 现在我们拿到了真正的标题
                    NSString *realTitle = [strHTML substringWithRange:stringRange];
                    // 创建一个新的字符串，让这个二级标题进去。
                    NSMutableString *secondTitle = [NSMutableString stringWithFormat:@"\n\n---\n\n## %@\n\n", realTitle];
                    NSLog(@"%@", secondTitle);
                    // 然后我们获取这个文本的正文部分，拷贝成一个字符串
                    NSString *mainText = [NSString stringWithContentsOfFile:getFile encoding:NSUTF8StringEncoding error:nil];
                    // 替换掉mainText中的不需要的部分，换成secondTitle
                    NSString *unusedText = [NSString stringWithFormat:@"---\nlayout: book\ntitle: %@\n---", realTitle];
                    NSString *trimmedString = [mainText stringByReplacingOccurrencesOfString:unusedText withString:secondTitle];
                    // 然后将这个字符串添加到content（总字符串）中去
                    [content appendString:trimmedString];
                    // 最后换一行
                    [content appendString:@"\n"];
                }
                else
                {
                    NSLog(@"字符串匹配失败!");
                }
            }

        }
        // 绝对不要输出content
        // 直接把它搞进md文件里去，听我的。
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        [fm createFileAtPath:fileTLCL contents:data attributes:nil];
        // 以data的文件内容创建result.md
        NSLog(@"已成功导出Markdown文本文件/Users/Shared/book/TLCL.md");
    }
    return 0;
}
