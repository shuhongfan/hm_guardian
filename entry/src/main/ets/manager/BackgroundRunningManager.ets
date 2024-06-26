import { bundleManager, wantAgent } from '@kit.AbilityKit'
import { process } from '@kit.ArkTS'
import { avSession } from '@kit.AVSessionKit'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'

class BackgroundRunningManager {
  // 申请长时任务
  async startBackgroundRunning() {
    const context = getContext()
    // 重点1: 提供音频后台约束能力，音频接入AVSession后，可以进行后台音频播放
    const session = await avSession.createAVSession(context, 'guardianSession', 'audio')
    await session.activate()
    // 获取 bundle 应用信息
    const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    // 通过wantAgent模块下getWantAgent方法获取WantAgent对象
    const wantAgentObj = await wantAgent.getWantAgent({
      // 添加需要被拉起应用的bundleName和abilityName
      wants: [{ bundleName: bundleInfo.name, abilityName: "EntryAbility" }],
      // 使用者自定义的一个私有值
      requestCode: 0,
    })
    // 重点2: 创建后台任务
    await backgroundTaskManager.startBackgroundRunning(context,
      backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj)
  }

  // 停止后台任务
  async stopBackgroundRunning() {
    backgroundTaskManager.stopBackgroundRunning(getContext())
  }
}

export const backgroundRunningManager = new BackgroundRunningManager()