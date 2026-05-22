# CLAUDE.md

本项目的核心用途：辅助用户优化简历内容、调整 LaTeX 样式、生成最终的 `src/resume.tex` 并编译 PDF。

## 常用命令

```bash
make pdf        # 编译 PDF（xelatex 跑两次，输出到 output/）
make open       # 编译并打开 PDF
make clean      # 清理辅助文件
make distclean  # 清理所有编译产物（含 PDF）
```

## 项目结构

- **`src/resume.md`** — 用户编辑的简历内容源文件。YAML front matter 放个人信息，Markdown 正文放各章节（教育经历、工作经历、项目经历、专业技能）。
- **`src/resume.tex`** — AI 自动生成的 LaTeX 文件。由 resume.md + templates 生成，用户不手动编辑。
- **`templates/style.sty`** — 视觉样式。颜色、字体、边距、间距、列表样式等，所有参数有中文注释。
- **`templates/cv.latex`** — 结构宏（`\makecvheader`、`\cvsection`、`\cvevent`、`\cvheading`、`\cvtech`、`\cvlabeled` 等）。
- **`Makefile`** — 从项目根目录编译，`resume.tex` 中的路径相对于项目根。

## 工作流程

1. 用户提出内容或样式变更
2. 读取 `src/resume.md` 和 `templates/style.sty`、`templates/cv.latex`
3. 如涉及简历内容变更，先改 `resume.md`，再同步生成 `resume.tex`
4. 如涉及样式变更，直接改 `style.sty`
5. 运行 `make pdf` 验证编译通过

## 参考项目：消防应急指挥系统（上海寰创）

用户在上海寰创的正职经历对应的代码仓库在 **`/Users/zhaozhiwen/CodeRepo/WVP/`**。

### 项目背景

这是一个消防应急指挥调度平台，用于统一管理和调度自组网 Mesh 设备及各类前端视频终端，支持 GIS 地图、设备监控、视频点播、语音对讲、预警告警等功能。在此基础上新增了**无人机接入与控制模块**。

### 无人机接入的真实技术方案

**采用的方式**：公司嵌入式团队自行开发了嵌入式程序，部署在硬件上并绑定在无人机上，通过硬件控制无人机。这个硬件又连接到公司的自组网基站，实现超远距离传输（>20km）。

**与 DJI Cloud API 的关系**：交互格式尽量参考 DJI Cloud API（https://developer.dji.com/doc/cloud-api-tutorial/cn/），但很多地方没有严格遵守。没有直接使用 DJI Cloud API 的原因是：(1) DJI Cloud API 必须借助遥控器，遥控距离有限；(2) 上云 API 自定义程度不够，不同机型支持差异大。

**关键结论**：简历中不要写"对接 DJI 云平台"，因为不是通过 DJI 官方云 API 实现的。准确的说法是"通过自组网硬件实现与无人机的远程通信"或"基于公司自组网实现无人机超远距离控制"。

### 代码结构

- **`wvpserver/dji-cloud/`** — Java SpringBoot 后端
  - `dji/control/` — 无人机相机和云台控制代码，从第三方 DJI demo 合并而来，**大部分未调通**
  - `dji/manage/` — 设备管理、直播流、拓扑、工作空间
  - `dji/media/` — 无人机媒体文件管理
  - 还有 Mesh 组网、WebRTC、ZLM 流媒体服务器集成等
- **`wvpui/wvp-ui/`** — Vue 3 + TypeScript 前端
  - Cesium 三维 GIS 地图
  - 无人机虚拟座舱（飞行控制面板、相机操作、OSD 遥测数据展示）
  - MQTT 客户端（`UranusMqtt`）用于直接接收无人机遥测
  - 航线规划（Cesium wayline 模块）
  - 直播流播放、设备管理、告警管理等

### 代码审计结论（用户真实贡献）

**写简历时必须注意**：

1. 后端的相机/飞行控制代码是第三方 demo 合进来的，用户不负责这些 SDK 的编写。`ControlServiceImpl` 中 `payloadCommands()` 方法的 `.checkCondition()` 是**被注释掉的**，验证层未启用。
2. 无人机的实时遥测数据（OSD、相机、心跳、飞行状态）是通过**前端 MQTT 直接订阅**接收的，不是通过后端转发。这是当时为了快速验证功能的**权衡决策**——硬件团队已在 MQTT broker 上跑通，后端做 MQTT→WebSocket 桥接层开发周期长。回头看这个设计不合理：前端暴露了 MQTT 连接细节，订阅逻辑散落在组件里，不利于数据缓存和权限控制。正确的做法应该是后端统一订阅 MQTT，处理业务逻辑后通过 WebSocket 推前端。写简历时不要包装成"优秀架构设计"，实事求是描述即可。面试被问到可以坦诚讲"当时为了快速交付选了简单方案，我知道更好的做法是什么"——这种反思能力是加分项。
3. DJI Cloud SDK（`cloud-sdk` 模块）是别人 demo 提供的，直接 copy 到项目中，用户不了解其内部实现，面试时不应作为自己的技术亮点来谈。

**用户的真实贡献**：

后端：
- `LiveStreamServiceImpl` — 直播流管理（ZLM 流媒体集成、Redis 引用计数、WebSocket 实时推送、`WsDeferredResultHolder` 异步结果处理）
- `ControlServiceImpl` — Controller 层编写、SDK 调用整合、部分自定义飞行配置方法（`flightConfigSet` 含限高校验、`confirmLanding`/`cancelConfirmLanding`）
- 设备管理相关的 40+ 个 Controller
- 设备在线稳定性：解决服务器重启后无人机无法自动恢复在线的问题——利用 Spring Event 监听服务启动就绪事件，通过 MQTT 向硬件广播自定义重启指令，触发无人机重新走上线流程，实现服务重启后的设备自动恢复

前端（贡献较大）：
- 自定义 `UranusMqtt` MQTT 客户端封装
- `useDroneControlMqttEvent` hook 处理无人机遥测事件
- Vue 3 + TypeScript + Cesium 三维 GIS 地图集成
- 无人机虚拟座舱 UI（飞行面板、相机控制、遥测展示）
- 航线规划（wayline Cesium 模块）
- 完整的前端日志系统（基于 Logline 开源组件）
- 各功能模块：Mesh 设备管理、WebRTC 视频、直播、告警等

**措辞规范**：
- 用"独立完成"描述用户真正从 0 到 1 做的东西（前端无人机座舱、MQTT 遥测客户端、前端日志系统）
- 用"负责/主导"描述用户主要参与并有深度理解的部分（直播流服务、性能优化、设备管理）
- 用"参与/联调"描述用户有贡献但不是主导的部分
- 绝不写用户无法在面试中 defend 的技术点（如 DJI Cloud SDK 实现细节）
- 修改项目描述前，先读 `/Users/zhaozhiwen/CodeRepo/WVP/` 中的代码确认事实

## 参考项目：数据同步与监控平台（北京流金岁月）

用户在流金岁月的实习经历对应的代码仓库在 **`/Users/zhaozhiwen/CodeRepo/LIUJINTECK/DataMagicMgt/`**。

### 代码结构

- **`datamagicmgtapi/`** — API 层，包含 19 个 Controller（数据审核、调度、监控、标签管理等）
- **`DataMagicMgtExecute/`** — 业务执行层，包含数据同步、清洗、监控、缓存等服务
- **`DataMagicMgtEntity/`** — 实体和注解层

### 关键贡献

- `RedundantFieldAspect` — 自定义注解 `@RedundantField` + `@IgnoreRedundant` + AOP 切面，请求进入前自动清理冗余字段
- `CacheDataMgt` — 应用启动管理器，定时缓存同步、配置热更新、错误日志上报
- `DigitalSurveillanceExec` — 数字化监控执行器（预警、同步状态监控、审核异常）
- JDK 动态代理 + 反射封装统一代理层（`AOPDuewith.Create`），解决多数据源下 Controller 重复实例化问题

### 注意

- 项目基于公司内部框架（FrameEntity/FrameUtils/ExecuteCommon），不是用户自己写的
- 项目走的时候只联调了一版，未稳定上线，不要写"稳定运行"
- 180 个端点是全仓库统计，不是用户一人写的，不要写具体数量

## 参考项目：仿B站弹幕视频网站（个人开源）

用户的个人开源项目对应的代码仓库在 **`/Users/zhaozhiwen/CodeRepo/bilibili/`**。

### 目录说明

- **`server/imooc-bilibili/`** — Java SpringBoot 后端（用户编写）
  - `imooc-bilibili-api/` — API 层
  - `imooc-bilibili-service/` — 业务服务层（含 strategy、config、util、websocket）
  - `imooc-bilibili-dao/` — 数据访问层（MyBatis + ES Repository）
- **`frontEnd/imooc-bilibili-vue/`** — Vue 前端（用户编写）
- **`reference/`** — 参考代码/标准答案，**不是用户写的，跳过不读**

### 关键实现

- **登录系统**：工厂 + 策略模式（`UserLoginFactory` + `UserGranter`），配置驱动注册新登录方式（PhoneGranter、EmailGranter），JWT 双 Token（access + refresh）
- **RBAC 权限**：`ApiLimitedRoleAspect`（接口级角色控制）+ `DataLimitedAspect`（数据级权限），AOP 切面实现
- **Elasticsearch 搜索**：Multi-Match 多字段匹配（title/nick/description），关键词高亮，多维度排序（时间/弹幕数/播放量），分页查询
- **RocketMQ**：动态发布推送订阅，异步削峰存储弹幕数据
- **WebSocket 弹幕**：实时弹幕推送，异步化存储
- **FastDFS 视频**：分片上传、断点续传、秒传
- **线程池优化**：自定义 ThreadPoolExecutor（5 核心/6 最大/60s 超时/LinkedBlockingQueue），数据聚合接口从 150ms→50ms