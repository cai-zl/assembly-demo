# assembly-demo

#### 介绍

spring-boot使用maven-assembly插件打zip包示例，lib、resources与自身程序目录分类，方便运维。

#### 获取方式

1. gitee地址: https://gitee.com/cailiangchen/assembly-demo.git
2. github地址: https://github.com/cai-zl/assembly-demo.git

#### 使用说明

1. 将resources下的目录bin、builder、logback.xml复制到自己的项目

2. 将pom.xml中的<build/>标签复制到自己的项目

3. 修改复制内容中的TODO注释

4. 解压打包后的zip包

| 状态                          | 命令               |
| :---------------------------- | ------------------ |
| 启动                          | bin/app.sh start   |
| 停止                          | bin/app.sh stop    |
| 重启                          | bin/app.sh restart |
| 运行状态                      | bin/app.sh status  |
| jvm占用信息,可参考优化jvm参数 | bin/app.sh dump    |