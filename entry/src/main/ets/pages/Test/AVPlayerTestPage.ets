import { avPlayerManager } from '../../manager'

@Entry
@Component
struct AVPlayerTestPage {
  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('播放音频')
            .onClick(() => {
              // 通过 avPlayer 播放 resources/rawfile 文件夹下的本地文件
              avPlayerManager.playByRawSrc('lab_call_ring.mp3')
              avPlayerManager.setLoop(true)
            })
          Button('停止音频')
            .onClick(() => {
              avPlayerManager.stop()
            })
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('AVPlayer')
    .titleMode(NavigationTitleMode.Mini)
  }
}