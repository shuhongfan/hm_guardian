import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { promptAction, router, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PrivacySettings, PRIVACY_SETTINGS } from '../common/constants';
import { JSON } from '@kit.ArkTS';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('/pages/Test/AudioCapturerTestPage'.slice(1), (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      // 持久化 PersistentStorage 整个项目一个字段只需初始化一次
      // 温馨提示：PersistentStorage 持久化在 DevEco Studio 5.0.3.400 前有问题，旧版本需写到 pages/Index 页面组件中
      PersistentStorage.persistProp('isHidePrivacy', false)
      // 隐私空间持久化UI状态
      PersistentStorage.persistProp<PrivacySettings>(PRIVACY_SETTINGS, {})
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  // 切前台
  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', '---- Ability onForeground');
  }

  // 切后台(回主页/最小化)
  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', '---- Ability onBackground');

    // 如何判断切后台时，时隐私空间的某个页面？
    // {"index":2,"name":"AuthPatternLockPage","path":"pages/Privacy/Auth/"}
    const routerState = router.getState()
    hilog.info(0x0000, 'testTag', '%{public}s', '---- Ability onBackground' + JSON.stringify(routerState));
    // 判断 path 路径中是否为 隐私空间 的路径
    if (routerState.path.includes('pages/Privacy')) {
      // 返回主页，自动销毁中间的页面
      router.back({
        url: 'pages/Index'
      })
    }
  }
}
