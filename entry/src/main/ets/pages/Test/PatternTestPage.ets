// xxx.ets
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct PatternLockExample {
  @State passwords: Number[] = []
  @State message: string = 'please input password!'
  // 图案密码锁组件-控制器
  private patternLockController: PatternLockController = new PatternLockController()

  build() {
    Column() {
      Text(this.message)
        .textAlign(TextAlign.Center)
        .margin(20)
        .fontSize(20)
      // 图案密码锁组件
      PatternLock(this.patternLockController)
        .sideLength(300)
        .circleRadius(15)
        .pathStrokeWidth(10)
        .activeColor('#B0C4DE')
        .selectedColor('#228B22')
        .pathColor('#90EE90')
        .autoReset(true)
        .onDotConnect((index: number) => {
          console.log("onDotConnect index: " + index)
          // 连接时触发
          promptAction.showToast({ message: '连接时触发' + index })
        })
        .onPatternComplete((input: Array<number>) => {
          // 输入完成触发（手松开）
          promptAction.showToast({ message: '输入完成触发' + input })
          // 输入的密码长度小于5时，提示重新输入
          if (input.length < 5) {
            this.message = 'The password length needs to be greater than 5, please enter again.'
            this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG)
            return
          }
          // 判断密码长度是否大于0
          if (this.passwords.length > 0) {
            // 判断两次输入的密码是否相同，相同则提示密码设置成功，否则提示重新输入
            if (this.passwords.toString() === input.toString()) {
              this.passwords = input
              this.message = 'Set password successfully: ' + this.passwords.toString()
              this.patternLockController.setChallengeResult(PatternLockChallengeResult.CORRECT)
            } else {
              this.message = 'Inconsistent passwords, please enter again.'
              this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG)
            }
          } else {
            // 提示第二次输入密码
            this.passwords = input
            this.message = "Please enter again."
          }
        })
      Column({ space: 10 }) {
        Button('重置组件状态')
          .onClick(() => {
            // 重置密码锁
            this.patternLockController.reset()
            this.passwords = []
            this.message = 'Please input password'
          })
        Button('设置图案密码正确')
          .onClick(() => {
            this.patternLockController.setChallengeResult(PatternLockChallengeResult.CORRECT)
          })
        Button('设置图案密码错误')
          .onClick(() => {
            this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG)
          })
      }
    }
    .width('100%')
    .height('100%')
  }
}
