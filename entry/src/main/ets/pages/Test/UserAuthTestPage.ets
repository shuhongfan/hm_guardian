import { userAuth } from '@kit.UserAuthenticationKit'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct UserAuthTestPage {
  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('查询支持的认证能力')
            .onClick(() => {
              try {
                // 查询支持的认证能力
                userAuth.getAvailableStatus(userAuth.UserAuthType.PIN, userAuth.AuthTrustLevel.ATL1)
                promptAction.showToast({ message: '当前设备中支持 userAuth 认证能力' })
              } catch (error) {
                // 不支持通过 catch 捕获错误信息
                AlertDialog.show({ message: JSON.stringify(error, null, 2) })
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