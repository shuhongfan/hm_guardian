// 用于讲解和测试 鸿蒙应用 权限的页面
import { abilityAccessCtrl, bundleManager } from '@kit.AbilityKit'

@Entry
@Component
struct PermissionsTestPage {
  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('检查授权')
            .onClick(() => {
              // 1. 获取程序访问控制管理
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