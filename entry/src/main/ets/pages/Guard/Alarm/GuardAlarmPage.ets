import { avPlayerManager, backgroundRunningManager, themeManager } from '../../../manager'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct GuardAlarmPage {
  @State circleOpacity: number = 0.3
  @State circleHeight: number = 100
  @State currentVolume: number = 5
  private intervalID: number = -1

  // 页面加载
  aboutToAppear() {
    // 播放警报声音
    avPlayerManager.playByRawSrc('lab_alarm.wav')
    // 循环播放
    avPlayerManager.setLoop(true)
    // 开启后台播放(熄屏播放)
    backgroundRunningManager.startBackgroundRunning()
  }

  // 页面销毁
  aboutToDisappear() {
    // 停止播放
    avPlayerManager.stop()
    // 停止后台任务
    backgroundRunningManager.stopBackgroundRunning()
  }

  onPageShow() {
    themeManager.settingStatusBarWhite()
  }

  onPageHide() {
    themeManager.settingStatusBarBlack()
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          Stack() {
            // 背景圆
            Row()
              .height(120)
              .aspectRatio(1)
              .borderRadius(120 / 2)
              .backgroundColor('#fff')
              .opacity(this.circleOpacity)
              .scale({ x: this.circleHeight / 120, y: this.circleHeight / 120 })
              .animation({
                duration: 2 * 1000, // 时长
                iterations: -1, // 设置-1表示动画无限循环
              })
              .onAppear(() => {
                // 组件挂载完毕，修改数值触发动画效果
                this.circleOpacity = 0
                this.circleHeight = 300
              })
            // 图标
            Image($r('app.media.ic_lab_ring'))
              .height(120)
              .aspectRatio(1)
              .borderRadius(120 / 2)
          }
          .margin({ top: -100 })
        }
        .justifyContent(FlexAlign.Center)
        .height('100%')

        // 底部按钮
        Column() {
          Button('结束警报')
            .type(ButtonType.Normal)
            .borderRadius(10)
            .width('100%')
            .fontColor('#000')
            .backgroundColor('#fff')
            .onClick(() => {
              // TODO: 结束警报
              router.back()
            })
        }
        .padding({ left: 20, right: 20, bottom: 30 })
      }
      .height('100%')
    }
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .backButtonIcon($r('app.media.ic_public_back_white'))
    .linearGradient({
      angle: 180,
      colors: [['#FF6A69', 0], ['#FF2121', 1]]
    })
  }
}