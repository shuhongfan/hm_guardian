import { avPlayerManager } from '../../manager'
import { avSession } from '@kit.AVSessionKit'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'
import { bundleManager, wantAgent } from '@kit.AbilityKit'

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

          Button('开启后台播放或熄屏播放')
            .onClick(async () => {
              // 1. 接入AVSession（媒体会话）
              const session = await avSession.createAVSession(getContext(), 'guardian_tag', 'audio')
              session.activate()
              // 获取 bundle 应用信息
              const bundleInfo =
                bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
              // 通过wantAgent模块下getWantAgent方法获取WantAgent对象
              const wantAgentObj = await wantAgent.getWantAgent({
                // 添加需要被拉起应用的 bundleName 和 abilityName
                wants: [{ bundleName: bundleInfo.name, abilityName: "EntryAbility" }],
                // 使用者自定义的一个私有值
                requestCode: 0,
              })
              // 2. 申请长时任务
              backgroundTaskManager.startBackgroundRunning(
                getContext(),
                backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, // 音频后台播放
                wantAgentObj
              )
            })

          Button('关闭后台长时任务')
            .onClick(() => {
              backgroundTaskManager.stopBackgroundRunning(getContext())
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