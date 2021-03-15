# NSCSCC bit-mips 2019
> 本仓库为北理工 2019 NSCSCC 2队参赛作品。


## 目录结构

|- func_test_v0.01 功能测试

|--- soc_axi_func 接口为 axi 的功能测试

|--- soc_sram_func 接口为 sram 的功能测试

|--- soft 89个功能点的测试软件，仅包含 coe 文件

|- perf_test_v0.01

|--- soc_axi_perf 接口为 axi 的性能测试

|--- soft 性能测试软件，仅包含 coe 文件

|- soc_demo 见 soc_demo 说明

|- perf_test_new 见 perf_test_new 说明

|- summary 比赛总结

|- README.md 本文档

## soc_demo 说明

soc_demo 为比赛结束之后根据龙芯提供的一个 soc 源码搭建的一个 soc，该 soc_demo 计划用来运行 ucore，与参赛作品不同的是，该 soc_demo 内的源码有所改动如下：
- 增加 tlb，共32项
- 重写 cache，新 cache 使用 bram 构建，指令 cache 和数据 cache 大小相同，都是 8kB，2 way，128 set/way，32 byte/set
- 新增部分 cp0 寄存器
- 修改部分 bug

截至 2019.10.21，由于还未发现的 bug，导致该 soc_demo 并不能完整稳定的运行 pmon 软件，之所以说不能完整稳定运行，是我们偶尔的还能将 pmon 运行起来，并能输入命令行，这个 bug 就很奇怪？

往后如果有可能，会将 soc_demo 的流水线核重新写一遍，这个流水线写的并不是很好，bug 很多。。。

2021.3.15 更新：目前已知的一个 bug 就是关于 lb, sb 等指令的实现方式有误，本实现是将 lb 等对字节，半字的操作转换为对字的操作，实际上应该根据 axi 协议严格地进行字节访存。由于现在没有时间和精力来维护这个库，所有先写在这里。

## perf_test_new 说明

后期改进版本，主要针对访存和 Cache 进行优化，目前该版本没有针对线路进行优化，因此 CPU 频率不能提到很高（估计不超过 60Mhz），但是可以到 50Mhz，在此频率下跑分为 27.7。

为减少提交文件体积，仅上次 `myCPU` 里的代码，如需跑通过代码，请根据龙芯发布包构建项目，将此目录下文件加入到项目中。 

## Authors

**[moon548834](https://github.com/moon548834)** **[Silverster](https://github.com/Silverster98)**
