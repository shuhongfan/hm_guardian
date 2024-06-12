// 用于讲解和测试 鸿蒙应用 权限的页面
import { abilityAccessCtrl, bundleManager, common } from '@kit.AbilityKit'

@Entry
@Component
struct PermissionsTestPage {
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
              AlertDialog.show({ message: JSON.stringify(requestResult, null, 2) })
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