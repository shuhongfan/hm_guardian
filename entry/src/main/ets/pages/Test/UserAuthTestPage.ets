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
                // 注意：先在模拟器的设置页，添加锁屏密码
                // 查询支持的认证能力
                userAuth.getAvailableStatus(userAuth.UserAuthType.PIN, userAuth.AuthTrustLevel.ATL1)
                promptAction.showToast({ message: '当前设备中支持 userAuth 认证能力' })
              } catch (error) {
                // 不支持通过 catch 捕获错误信息
                AlertDialog.show({ message: JSON.stringify(error, null, 2) })
              }
            })
          Button('发起认证-userAuth')
            .onClick(() => {
              // 申请权限：ohos.permission.ACCESS_BIOMETRIC。
              // 1. 调用 getUserAuthInstance 获取认证对象。
              //     1.1 指定用户认证相关参数AuthParam（包括挑战值、认证类型UserAuthType列表和认证等级AuthTrustLevel）、配置认证控件界面WidgetParam，
              // 2. 调用 UserAuthInstance.on 接口订阅认证结果。
              // 3. 调用 UserAuthInstance.start 接口发起认证
              //      通过IAuthCallback回调返回认证结果UserAuthResult。
              //      当认证成功时返回认证通过类型（UserAuthType）和令牌信息（AuthToken）。

              // 1. 获取认证对象
              const userAuthInstance = userAuth.getUserAuthInstance(
                {
                  challenge: new Uint8Array([1, 1, 2, 3, 4, 5, 51]), // 挑战值
                  authType: [userAuth.UserAuthType.PIN, userAuth.UserAuthType.FINGERPRINT, userAuth.UserAuthType.FACE],
                  authTrustLevel: userAuth.AuthTrustLevel.ATL3
                },
                { title: '请验证用户身份' }
              )
              // 2. 订阅认证结果
              userAuthInstance.on('result', {
                onResult(result) {
                  AlertDialog.show({ message: JSON.stringify(result, null, 2) })
                }
              })
              // 3. 发起认证
              userAuthInstance.start()
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