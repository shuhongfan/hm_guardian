// 用于讲解和测试 鸿蒙应用 权限的页面
import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { permissionManager, themeManager } from '../../manager';

// 官方文档：https://docs.openharmony.cn/pages/v4.1/zh-cn/application-dev/security/AccessToken/request-user-authorization.md
// 如何化简官方文档的例子:
// 以 向用户申请授权 -> 开发步骤 -> 2.校验当前是否已经授权  为例，
// 官方文档示例有 40 行，优化后核心代码其实只有 3 行
// 化简代码步骤：
//   1. 删除非必要的类型定义
//   2. 删除非必要的 try catch 和 console
//   3. 合并冗余代码，优化代码
function checkAccessToken(permission: Permissions) {
  let atManager = abilityAccessCtrl.createAtManager();
  let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
  return atManager.checkAccessTokenSync(bundleInfo.appInfo.accessTokenId, permission);
}

// 打开应用设置页的函数封装，写法固定
function openSettingPage() {
  // 1. 获取应用上下文，并通过 as 断言收窄类型为 UIAbilityContext，否则 context 默认类型无法调用 startAbility 方法
  const context = getContext() as common.UIAbilityContext
  // 2. 获取 bundle 包信息
  const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag
    .GET_BUNDLE_INFO_WITH_APPLICATION)
  // 3. 通过 startAbility 打开 系统设置 页
  context.startAbility({
    bundleName: 'com.huawei.hmos.settings', // 固定写法CV：设置页的包名
    abilityName: 'com.huawei.hmos.settings.MainAbility', // 固定写法CV：设置页的 ability 名
    uri: 'application_info_entry', // 固定写法CV：打开 设置->应用和元服务
    parameters: {
      // 打开指定应用(包)的详情页面
      // pushParams: 'com.itheima.hm_guardian'
      // 应用包名可通过 bundleManager 动态获取
      pushParams: bundleInfo.name
    }
  })
}

@Entry
@Component
struct PermissionsTestPage {
  // 页面加载时
  aboutToAppear() {
    // 测试 manager 导入
    themeManager.enableFullScreen()
    permissionManager.checkPermissions([])
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('检查授权')
            .onClick(() => {
              // 1. 创建应用权限管理器
              const atManager = abilityAccessCtrl.createAtManager()
              // 2. 获取 bundle 包信息
              const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag
                .GET_BUNDLE_INFO_WITH_APPLICATION)
              // AlertDialog.show({ message: JSON.stringify(bundleInfo, null, 2) })
              // 3. 提取 tokenID
              const tokenID = bundleInfo.appInfo.accessTokenId
              // 4. 检测是否授权
              const grantStatus = atManager.checkAccessTokenSync(tokenID, 'ohos.permission.READ_CALENDAR')
              // AlertDialog.show({ message: JSON.stringify(grantStatus, null, 2) })
              if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
                AlertDialog.show({ message: '已授权' })
              } else if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
                AlertDialog.show({ message: '授权失败/未授权/拒绝授权' })
              }
            })
          Button('申请权限，授权方式：user_grant')
            .onClick(async () => {
              // 1. 创建应用权限管理器
              const atManager = abilityAccessCtrl.createAtManager()
              // 2. 向用户申请 user_grant 权限（温馨提示：首次申请时会弹窗，后续申请则不会再出现弹窗）
              const requestResult = await atManager.requestPermissionsFromUser(
                getContext(), // 应用上下文
                ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR']  // 权限列表(数组)
              )
              // 测试代码
              // AlertDialog.show({ message: JSON.stringify(requestResult, null, 2) })
              // every 检查权限的是否都授权
              const isAuth =
                requestResult.authResults.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)

              if (isAuth === true) {
                // 如果已授权，直接调用 API 即可
                promptAction.showToast({ message: '可以调用该权限' })
              } else {
                // 如果禁止授权，先弹窗询问，用户点击按钮后打开设置页
                promptAction.showDialog({
                  alignment: DialogAlignment.Center,
                  title: '温馨提示',
                  message: '使用日历功能需要权限，请到设置页中开启',
                  buttons: [
                    { text: '取消', color: $r('app.color.font_sub') },
                    { text: '去设置', color: $r('app.color.brand') },
                  ]
                })
                  .then((res) => {
                    // 用户点击了去设置
                    if (res.index === 1) {
                      // 通过代码打开当前应用的设置页
                      openSettingPage()
                    }
                  })
              }
            })
          Button('通过代码打开应用设置页')
            .onClick(() => {
              // 1. 获取应用上下文，并通过 as 断言收窄类型为 UIAbilityContext，否则 context 默认类型无法调用 startAbility 方法
              const context = getContext() as common.UIAbilityContext
              // 2. 获取 bundle 包信息
              const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag
                .GET_BUNDLE_INFO_WITH_APPLICATION)
              // 3. 通过 startAbility 打开 系统设置 页
              context.startAbility({
                bundleName: 'com.huawei.hmos.settings', // 固定写法CV：设置页的包名
                abilityName: 'com.huawei.hmos.settings.MainAbility', // 固定写法CV：设置页的 ability 名
                uri: 'application_info_entry', // 固定写法CV：打开 设置->应用和元服务
                parameters: {
                  // 打开指定应用(包)的详情页面
                  // pushParams: 'com.itheima.hm_guardian'
                  // 应用包名可通过 bundleManager 动态获取
                  pushParams: bundleInfo.name
                }
              })
            })
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('')
    .titleMode(NavigationTitleMode.Mini)
  }
}