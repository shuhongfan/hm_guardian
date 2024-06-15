import { Permissions } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { permissionManager } from '.'
import { dataSharePredicates } from '@kit.ArkData'
import { formatByteLength, KILO_BYTE } from '../common/utils'
import { image } from '@kit.ImageKit'
import { fileIo } from '@kit.CoreFileKit'

class CleanerManager {
  // 权限
  private permissions: Permissions[] = ["ohos.permission.READ_IMAGEVIDEO", "ohos.permission.WRITE_IMAGEVIDEO"]
  // 图片资源
  private photoAssets: photoAccessHelper.PhotoAsset[] = []
  // 图片字段
  private fetchColumns: photoAccessHelper.PhotoKeys[] = [
    photoAccessHelper.PhotoKeys.DATE_ADDED,
    photoAccessHelper.PhotoKeys.SIZE,// 图片文件大小
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

  // 获取所有图片/视频
  async getAssets() {
    // 1. 建立检索条件，用于获取图片资源。
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
    const predicates = new dataSharePredicates.DataSharePredicates()
    // 2. 调用 PhotoAccessHelper.getAssets 接口获取目标图片资源。
    const fetchResult = await phAccessHelper.getAssets({
      fetchColumns: this.fetchColumns,
      predicates,
    })
    // 3. 调用 FetchResult.getFirstObject 接口获取第一张图片，即要放入回收站的图片对象。
    const photoAssets = await fetchResult.getAllObjects()
    // 返回图片资源
    return photoAssets
  }

  // 获取屏幕截图列表
  async getScreenshotList() {
    // 获取所有图片/视频
    const photoAssets = await this.getAssets()
    // 截图相册目前不对第三方应用开放，可自己通过 filter 过滤出 screenshot 截图开头的图片资源实现
    return photoAssets.filter(item => item.displayName.includes('screenshot'))
  }

  // 获取视频列表
  async getVideoList() {
    // 获取所有图片/视频
    const photoAssets = await this.getAssets()
    // 过滤出视频 PhotoType 为 VIDEO
    return photoAssets.filter(item => item.photoType === photoAccessHelper.PhotoType.VIDEO)
  }

  // 获取大尺寸图片，用于压缩
  async getLargeSizeList() {
    // 获取所有图片/视频
    const photoAssets = await this.getAssets()
    // 过滤出 超过 200 kb，根据情况进行调整，模拟器只能截图，图片尺寸都比较小，如果是真机，可以设置为超过 2M
    const largeSize = 200 * KILO_BYTE
    return photoAssets.filter(item => item.get(photoAccessHelper.PhotoKeys.SIZE) as number > largeSize)
  }

  // 删除图片
  async deletePhotos(uris: string[]) {
    // 获取所有图片/视频
    const photoAssets = await this.getAssets()
    const list = photoAssets.filter(item => uris.includes(item.uri))
    // 删除图片
    return photoAccessHelper.MediaAssetChangeRequest.deleteAssets(getContext(), list)
  }

  // 压缩图片
  async compressImage(uri: string) {
    // 创建图片打包器
    const imagePacker = image.createImagePacker()
    // 坑点：createImageSource 不能直接使用 uri，需要先基于 uri 打开文件，再传入文件的 fd
    const file = fileIo.openSync(uri)
    // createImageSource 传入文件标识 fd，获取图片源
    const imageSource = image.createImageSource(file.fd)
    // 图片打包
    //  参数1: 图片源
    //  参数2: 打包配置：格式、质量 为必传参数
    const arrayBuffer = await imagePacker.packing(imageSource, { format: 'image/jpeg', quality: 10 })
    AlertDialog.show({ message: '压缩后文件流大小为：' + formatByteLength(arrayBuffer.byteLength) })
  }
}

export const cleanerManager = new CleanerManager()