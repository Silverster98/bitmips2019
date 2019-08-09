# NSCSCC bit-mips 2019
> 本仓库为 bit 2019 NSCSCC 参赛作品。

### master 分支
最终提交作品是位于 master 分支的代码。master 分支自实现 cache。

### system_cache 分支
该分支使用system cache ip 核，并且若日后实现 tlb 也在该分支。

### master 目录结构：
|- bitmips2019

|--- bitmips/ mips具体实现的 vivado 项目

|------ bitmips.xpr :bitmips vivado 工程，可直接使用vivado打开

|--- soc_sram_func/ 龙芯soc功能测试，sram接口，使用同目录下的soft测试文件

|--- soc_axi_func/ 龙芯soc功能测试，axi接口，使用同目录下的soft测试文件

|--- soft/ 功能测试代码 

|--- perf_test_v0.01/ 龙芯soc性能测试，axi接口

|--- mips框图说明.txt :架构图说明

|--- README.md :本文档

|--- .gitignore :gitignore

### 文件补全说明

- 若要进行trace对比，需要将cpu123_gettrace放在与soc_axi_func/同目录下 【可选】

- perf_test_v0.01/ 目录下需补全性能测试代码　soft/　文件夹　【必须】

- perf_test_v0.01/soc_axi_perf/rtl/　目录下补全性能测试文件的　xilinx_ip/　文件夹　【必须】
