import { Permissions } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { permissionManager } from '.'

class AudioCapturerManager {
  // 权限
  private permissions: Permissions[] = ["ohos.permission.MICROPHONE"]

  // 初始化权限
  async requestPermissions() {
    // 申请权限
    try {
      // 申请权限
      await permissionManager.requestPermissions(this.permissions)
    } catch {
      // 未开启弹窗提示
      promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: '录音功能需要获取权限，请在系统设置中打开麦克风开关',
        buttons: [
          { text: '取消', color: $r('app.color.font_sub') },
          { text: '立即开启', color: $r('app.color.brand') }
        ]
      })
        .then((res) => {
          // 打开设置页
          if (res.index === 1) {
            permissionManager.openPermissionSettingsPage()
          }
        })
    }
  }
}

export const audioCapturerManager = new AudioCapturerManager()