# 这是啥？

DafaWebCache 是一个 Cocoa 环境下用来缓存 URL/HTML 的库，Dafa我养的一只猫。

你可以在这里看到它的照片：
http://shiweifu.lofter.com/post/8293b_854ca22

# 解决了啥？

有时候会有一些缓存HTML或URL的需求，这个时候，有个问题就是如果单单只缓存了URL对应的页面，那么离线下图片和CSS都是未被缓存的。DafaWebCache解决了这个问题。你不用再担心缓存CSS和图片的问题，它会搞定。

# 工作原理

1. 使用 NSOperation 在后台进行下来
2. 解析页面，通过正则表达式获取页面中的图片和CSS
3. 将页面、图片、CSS一起当作二进制数据写入到SQLite数据库中
4. 发送通知

# 存在问题

 - 如果网页很大，会比较慢
 - 稳定性

# TODO

 - 补充测试用例
 - 加入请求超时和出错反馈

# 那么，然后呢？

 - star本项目
 - 提issue
 - 欢迎给王大发捐赠猫粮


# 联系方式

 - 支付宝：shiweifu@gmail.com  
 - wechat：kernel32

