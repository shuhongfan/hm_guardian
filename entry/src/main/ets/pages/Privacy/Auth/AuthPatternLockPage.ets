import { router } from '@kit.ArkUI'
import CryptoJS from '@ohos/crypto-js'
import { PRIVACY_SETTINGS, PrivacySettings } from '../../../common/constants'
import { encryptMD5 } from '../../../common/utils'
import { userAuthManager } from '../../../manager'
import { vibrator } from '@kit.SensorServiceKit'

@Entry
@Component
struct AuthPatternLockPage {
  // 获取 AppStorage 的数据
  @StorageLink(PRIVACY_SETTINGS) privacySettings: PrivacySettings = {}
  // 输入的密码
  @State inputPasswords: number[] = []
  // 错误提示语
  @State errorMessage: string = ''
  // 错误输入次数
  @State errorInputCount: number = 0
  // 是否允许操作
  @State isEnable: boolean = true
  // 定时器，用于清空提示文案
  private timeoutID: number = -1
  // 图形密码控制器
  private patternLockController: PatternLockController = new PatternLockController()

  // 设置错误信息
  setErrorMessage(message: string) {
    // 设置错误提示语
    this.errorMessage = message
    // 标记为错误
    this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG)
  }

  // 清空错误信息
  clearErrorMessage() {
    // 清空错误提示语
    this.errorMessage = ''
    // 标记为正确
    this.patternLockController.setChallengeResult(PatternLockChallengeResult.CORRECT)
  }

  // 密码输入结束时触发该回调
  onPatternComplete(input: number[]) {
    // 临时密码，用于更新线条颜色用的（用户体验提升）
    this.inputPasswords = input

    // 1. 判断输入的长度
    if (input.length < 4) {
      // 设置错误提示语，更新组件状态为错误
      this.setErrorMessage('密码长度不小于4位，请重新输入')
    } else {
      this.clearErrorMessage()
      // 2. 对比密码
      //  由于持久化存储的是加密后的密码，所以当前输入的密码也需要先加密，再进行比较
      if (this.privacySettings.patternPassword === encryptMD5(input.toString())) {
        router.pushUrl({ url: 'pages/Privacy/PrivacyIndexPage' })
      } else {
        this.setErrorMessage('密码错误，请重新输入')
      }
    }

    // 输入完成后，清空界面（用户体验提升）
    this.timeoutID = setTimeout(() => {
      // 清空图案锁界面
      this.patternLockController.reset()
      // 重置临时密码，用于恢复线条颜色
      this.inputPasswords = []
    }, 500)
  }

  // 测试用的代码
  // aboutToAppear(): void {
  //   // 测试
  //   const hash = CryptoJS.MD5('123456')
  //   const hash2 = CryptoJS.MD5('123456')
  //   AlertDialog.show({ message: 'hash：' + hash.toString() })
  //   AlertDialog.show({ message: 'hash2：' + hash2.toString() })
  // }
  aboutToAppear() {
    // 页面加载完毕，开始生物识别认证
    this.startUserAuth()
  }

  // 生物识别认证
  async startUserAuth() {
    // 先检查能力
    if (userAuthManager.checkUserAuthSupport()) {
      // 开启认证
      await userAuthManager.startUserAuth()
      // 认证成功跳转主页
      router.pushUrl({ url: 'pages/Privacy/PrivacyIndexPage' })
    }
  }

  build() {
    Column() {
      // 标题
      Navigation() {
        Column() {
          Text('patternPassword：' + this.privacySettings.patternPassword)
          Text('passwords：' + this.inputPasswords.toString())
        }

        Column({ space: 20 }) {
          Column({ space: 10 }) {
            // 请输入密码
            Text(this.isEnable ? '请输入密码' : '隐私空间已锁定')
              .fontSize(16)
              .fontColor($r('app.color.font'))
            if (this.errorMessage) {
              Text(this.errorMessage)
                .fontSize(12)
                .fontColor($r('app.color.danger'))
            } else {
              Text('输入密码进入隐私空间')
                .fontSize(12)
                .fontColor($r('app.color.font_sub'))
            }
          }

          PatternLock(this.patternLockController)
            .sideLength(320)// 宽高
            .circleRadius(12)// 圆点半径
            .pathStrokeWidth(10)// 线宽度
            .regularColor('#ffd9d9d9')// 未选中圆点色
            .activeColor('#800a59f7')// 经过圆点色
            .selectedColor(this.errorMessage && this.inputPasswords.length !== 0 ? '#ffff5e5d' : '#ff0a59f7')// 选中圆点色
            .pathColor(this.errorMessage && this.inputPasswords.length !== 0 ? '#ccff5e5d' : '#cc0a59f7')// 线颜色
            .enabled(this.isEnable)
            .onDotConnect(() => {
              // 使用预置的振动效果增强触摸反馈
              vibrator.startVibration(
                { type: 'preset', effectId: vibrator.EffectId.EFFECT_CLOCK_TIMER, count: 1 },
                { usage: 'touch' }
              )
              // 密码输入选中宫格圆点时触发该回调
              clearTimeout(this.timeoutID)
            })
            .onPatternComplete((input: number[]) => {
              // TODO：密码输入结束时触发该回调
              this.onPatternComplete(input)
            })

          Row({ space: 20 }) {
            Text('忘记密码')
              .fontSize(14)
              .fontColor($r('app.color.font2'))
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/Privacy/Auth/ForgetPasswordPage',
                })
              })
          }
        }
        .padding({ top: 140 })
      }
      .title('隐私空间')
      .titleMode(NavigationTitleMode.Mini)
      .mode(NavigationMode.Stack)
      .hideTitleBar(false)
    }
    .height('100%')
  }
}