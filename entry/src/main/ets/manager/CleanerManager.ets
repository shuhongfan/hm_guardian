import { Permissions } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { permissionManager } from '.'

class CleanerManager {
  // 权限
  private permissions: Permissions[] = ["ohos.permission.READ_IMAGEVIDEO", "ohos.permission.WRITE_IMAGEVIDEO"]
  // 图片资源
  private photoAssets: photoAccessHelper.PhotoAsset[] = []
  // 图片字段
  private columns: photoAccessHelper.PhotoKeys[] = [
    photoAccessHelper.PhotoKeys.DATE_ADDED,
    photoAccessHelper.PhotoKeys.SIZE,
  ]

  // 图片权限
  async requestPermissions() {
    try {
      // 申请权限
      await permissionManager.requestPermissions(this.permissions)
    } catch {
      // 未开启弹窗提示
      const dialogRes = await promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: '手机瘦身功能需要获取权限，请在系统设置中打开相册开关',
        buttons: [
          { text: '取消', color: $r('app.color.font_sub') },
          { text: '立即开启', color: $r('app.color.brand') }
        ]
      })
      // 打开设置页
      if (dialogRes.index === 1) {
        permissionManager.openPermissionSettingsPage()
      }
    }
  }

  // 获取图片/视频
  async getAssets() {

  }

  // 获取屏幕截图列表
  async getScreenshotList() {

  }

  // 获取视频列表
  async getVideoList() {

  }

  // 删除图片
  async deletePhotos(uris: string[]) {

  }
}

export const cleanerManager = new CleanerManager()