# NSCSCC bit-mips 2019
> 本仓库为北理工 2019 NSCSCC 参赛作品。


## 目录结构

|- func_test_v0.01 功能测试

|--- soc_axi_func 接口为 axi 的功能测试

|--- soc_sram_func 接口为 sram 的功能测试

|--- soft 89个功能点的测试软件，仅包含 coe 文件

|- perf_test_v0.01

|--- soc_axi_perf 接口为 axi 的性能测试

|--- soft 性能测试软件，仅包含 coe 文件

|- soc_demo 见 soc_demo 说明

|- summary 比赛总结

|- README.md 本文档

## soc_demo 说明

soc_demo 为比赛结束之后根据龙芯提供的一个 soc 源码搭建的一个 soc，该 soc_demo 计划用来运行 ucore，与参赛作品不同的是，该 soc_demo 内的源码有所改动如下：
- 增加 tlb，共32项
- 重写 cache，新 cache 使用 bram 构建，指令 cache 和数据 cache 大小相同，都是 8kB，2 way，128 set/way，32 byte/set
- 新增部分 cp0 寄存器
- 修改部分 bug

截至 2019.10.21，由于还未发现的 bug，导致该 soc_demo 并不能完整稳定的运行 pmon 软件，之所以说不能完整稳定运行，是我们偶尔的还能将 pmon 运行起来，并能输入命令行，这个 bug 就很奇怪？

往后如果有可能，回将 soc_demo 的流水线核重新写一遍，这个流水线写的并不是很好，bug 很多。。。

## Authors

**[moon548834](https://github.com/moon548834)** **[Silverster](https://github.com/Silverster98)**
