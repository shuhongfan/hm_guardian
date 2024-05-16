## 目录结构

```
src
├── entryability
│   └── EntryAbility.ets
├── common // 公共封装
│   ├── builders       // 自定义 builder
│   ├── components     // 自定义组件
│   ├── constants      // 自定义常量
│   ├── dialog         // 自定义对话框
│   ├── images         // 图像资源
│   ├── uploads        // 测试的图像资源
│   └── utils          // 通用工具函数
├── manager                     // 管理器模块
│   ├── PermissionManager.ets   // 用户权限管理器
│   ├── ThemeManager.ets        // 主题管理器
│   └── index.ets               // 管理器模块入口
└── pages // 项目页面
    ├── Index.ets                   // 应用主页
    ├── Tabs
    │   ├── HomeTabsComp.ets        // 首页
    │   ├── GuardTabsComp.ets       // 守护中心
    │   └── MyTabsComp.ets          // 我的
    ├── Battery  // 电池管家
    │   └── BatteryIndexPage.ets        // 电池管家主页
    ├── Calendar // 日历清理
    │   ├── CalendarIndexPage.ets       // 日历清理主页
    │   ├── CalendarFraudPge.ets        // 诈骗日历
    │   ├── CalendarOverduePage.ets     // 过期日历
    │   └── CalendarSearchPage.ets      // 搜索日历
    ├── Cleaner  // 手机瘦身
    │   ├── CleanerIndexPage.ets        // 手机瘦身主页
    │   ├── CleanerSelectPage.ets       // 选择清理的页面
    │   └── Compress
    │       └── CompressPhotoPage.ets   // 照片压缩（图片瘦身）
    ├── Contact  // 通讯录 
    │   ├── ContactIndexPage.ets           // 通讯录备份主页
    │   ├── ContactHistoryDetailPage.ets   // 备份历史详情页
    │   ├── ContactHistoryPage.ets         // 备份历史
    │   ├── ContactMergePage.ets           // 合并联系人
    │   ├── ContactOptimizePage.ets        // 优化联系人
    │   ├── ContactSettingsPage.ets        // 通讯录设置页
    │   └── ContactUnknownPage.ets         // 异常联系人
    ├── Guard   // 守护中心
    │   ├── EmergencyContactPage.ets    // 紧急联系人
    │   ├── Indoor
    │   │   ├── IndoorCheckMovePage.ets   // 手机防移动
    │   │   ├── CheckCameraPage.ets       // 摄像头检测
    │   │   └── IndoorIndexPage.ets       // 室内守护
    │   ├── Alarm
    │   │   ├── CountdownPage.ets       // 警报器倒计时
    │   │   └── GuardAlarmPage.ets      // 警报器页面
    │   ├── Fake
    │   │   ├── FakeTelPage.ets         // 伪装来电
    │   │   └── FakeVoicePage.ets       // 伪装声音
    │   └── Outdoor
    │       ├── GuardNightPage.ets        // 夜路守护
    │       └── GuardPolicePage.ets       // 附近派出所
    ├── Hardware
    │   └── HardwareIndexPage.ets         // 硬件信息页
    ├── Privacy  // 隐私空间
    │   ├── PrivacyIndexPage.ets          // 隐私空间主页
    │   ├── PrivacySettingsPage.ets       // 隐私空间设置页
    │   ├── Auth
    │   │   ├── AuthPatternLockSettingsPage.ets      // 图案锁设置
    │   │   ├── AuthPatternLockPage.ets              // 图案锁认证
    │   │   ├── AuthProtectPage.ets                  // 密保页面
    │   │   └── ForgetPasswordPage.ets               // 忘记密码
    │   ├── Note
    │   │   └── NoteIndexPage.ets       // 隐私笔记主页
    │   │   ├── NoteFormPage.ets        // 隐私笔记表单页
    │   └── Recorder
    │       └── RecorderIndexPage.ets   // 隐私录音
    │   ├── Photo
    │   │   ├── PhotoIndexPage.ets     // 隐私照片主页
    │   │   ├── PhotoAddPage.ets       // 添加照片
    │   │   └── PhotoPreviewPage.ets   // 预览照片
    ├── Settings
    │   ├── SettingsIndexPage.ets         // 设置主页
    │   └── SettingsPermissionPage.ets    // 权限管理
    └── User
        └── UserLoginPage.ets       // 用户登录页
```