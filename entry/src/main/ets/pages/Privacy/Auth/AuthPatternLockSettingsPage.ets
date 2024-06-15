import { promptAction, router } from '@kit.ArkUI'
import { PRIVACY_SETTINGS, PrivacySettings } from '../../../common/constants'

interface RouterParams {
  isForgetPassword?: boolean
}

// 图案密码锁(手势密码) - 密码设置页
@Entry
@Component
struct AuthPatternLockSettingsPage {
  // 获取隐私空间设置
  @StorageLink(PRIVACY_SETTINGS) privacySettings: PrivacySettings = {}
  // 正在输入的图形密码
  @State inputPassword: number[] = []
  // 第一次输入的密码
  @State firstPassword: number[] = []
  // 错误提示语
  @State errorMessage: string = ''
  // 路由参数
  @State routerParams: RouterParams = {}
  // 定时器，用于清空提示文案
  private timeoutID: number = -1
  // 控制器
  private patternLockController: PatternLockController = new PatternLockController()

  // TODO：密码输入结束时触发该回调
  onPatternComplete(input: number[]) {
    // 保存临时的密码(更新线条颜色用的)
    this.inputPassword = input
    // 判断密码长度
    if (input.length < 4) {
      // 设置为错误
      this.errorMessage = '手势密码长度不能小于4位，请重新输入'
      this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG)
    } else {
      // 设置为正确
      this.errorMessage = ''
      this.patternLockController.setChallengeResult(PatternLockChallengeResult.CORRECT)
      // 是否为首次输入，firstPassword 数组为空
      if (this.firstPassword.length === 0) {
        // 保存首次输入的密码
        this.firstPassword = input
      } else {
        // [] === []  结果为 false，因为对象的对比的是内存地址
        // [1,2,3] 转换成字符串 => '1,2,3' 后再比较
        // 对比首次输入的密码 firstPassword 和 当前输入的 input
        if (this.firstPassword.toString() === input.toString()) {
          promptAction.showToast({ message: '两次密码相同' })
        } else {
          this.errorMessage = '两次输入的密码不相同'
          this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG)
        }
      }
    }

    // 输入结束，清空图形界面
    this.timeoutID = setTimeout(() => {
      this.patternLockController.reset()
      // 清空临时密码(更新线条颜色用的)
      this.inputPassword = []
    }, 500)
  }

  build() {
    Navigation() {
      Column() {
        Text('当前临时输入的密码：' + this.inputPassword)
        Text('首次输入的密码：' + this.firstPassword)
      }

      Column({ space: 20 }) {
        Column({ space: 10 }) {
          // 请输入密码
          Text(this.firstPassword.length === 0 ? '设置手势密码' : '再次确认手势密码')
            .fontSize(16)
            .fontColor($r('app.color.font'))
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(12)
              .fontColor($r('app.color.danger'))
          } else {
            Text(this.firstPassword.length === 0 ? '请绘制手势密码，至少链接4个点' : '请再次输入确认手势密码')
              .fontSize(12)
              .fontColor($r('app.color.font_sub'))
          }
        }

        PatternLock(this.patternLockController)
          .sideLength(320)// 宽高
          .circleRadius(12)// 圆点半径
          .pathStrokeWidth(10)// 线宽度
          .regularColor('#d9d9d9')// 未选中圆点色
          .activeColor('#800a59f7')// 经过圆点色
          .selectedColor(this.errorMessage && this.inputPassword.length !== 0 ? '#ffff5e5d' : '#ff0a59f7')// 选中圆点色
          .pathColor(this.errorMessage && this.inputPassword.length !== 0 ? '#ccff5e5d' : '#cc0a59f7')// 线颜色
          .onDotConnect(() => {
            // 密码输入选中宫格圆点时触发该回调
            clearTimeout(this.timeoutID)
          })
          .onPatternComplete((input: number[]) => {
            this.onPatternComplete(input)
          })
      }
      .padding({ top: 140 })
    }
    .title('隐私空间')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }
}