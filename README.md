# Advertisement Putting
基于以太坊的积分墙。广告主可以在该系统中投放广告，并注入ProToken；白名单内的用户通过点击广告来赚取ProToken，同时为广告主投放广告的媒体方亦获得ProToken奖励。

### 一、系统架构

![flow2](flow2.png)

### 二、资金流向

![flow1](flow1.jpeg)

### 三、技术细节

1. 技术栈
   - 后端
     - 使用Solidity语言基于remix开发以太坊智能合约；
     - 利用truffle框架进行编译、部署和测试；
     - 在testrpc, Ropsten, Rinkeby上进行ERC20代币发布和合约部署，并进行充分测试。
   - 前端
     - 使用ant, react开发框架，实现响应式布局、滑动式广告播放等特效；
     - 利用nodejs/web3与后端/智能合约进行交互

### 四、优化

- 辰星（密码学？）

### 五、形式化验证

1. 背景

   传统的软件测试方法无法保证百分之百的覆盖率，测试用例的设计有时较为困难；同时由于以太坊上Dapp的质量关系财产安全，以及合约部署后无法更改。这些都要求我们使用形式化验证方法对系统的安全性、合约的正确性进行保证。以太坊创始人Vitalik Buterin在各地演讲均强调Formal Verification的急迫性，因此我们考虑对该系统进行形式化验证。

2. 方法概述

   利用Promela语言对合约进行重写，通过数据结构约简优化state vector的大小；同时用SPIN对模型进行仿真和验证，即可得到最终验证结果。

3. 实施细节

   我们建模的原则即将contract里的每个function的行为建模成一个Promela的“proctype”；合约之间的通信，我们使用Global Variables和Channel。我们利用Promela的statement blocked机制和atomic语句块，来确保合约的执行顺序。

4. 属性描述

   我们使用LTL(线性时态逻辑)对系统的Safety/Liveness属性进行描述。

   1. 用户点击广告后，在满足各项条件时，最终余额总会增加广告中所要奖励的Token数

   2. 用户重复点击同一广告不会被“双重支付”

      ...

### 六、团队成员

- 合约开发：李辰星、曾丽仪、于千山
- 前端开发：谭旭、侯佳莹、夏提克
