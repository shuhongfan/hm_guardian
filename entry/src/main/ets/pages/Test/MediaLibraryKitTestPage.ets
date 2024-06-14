import { permissionManager } from '../../manager'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { picker } from '@kit.CoreFileKit'
import { dataSharePredicates } from '@kit.ArkData'

@Entry
@Component
struct MediaLibraryKitTestPage {
  // 媒体文件(图库) 是否授权
  @State isAuth: boolean = false
  // 图片数量
  @State photoCount: number = 0
  // 图片路径
  @State photoAssetUri: string = ''
  // 图片名称
  @State photoAssetDisplayName: string = ''

  aboutToAppear() {
    // 申请权限
    this.requestPermission()
  }

  // 申请权限
  async requestPermission() {
    // 申请媒体文件(图库)权限
    this.isAuth = await permissionManager.requestPermissions([
      'ohos.permission.READ_IMAGEVIDEO', // 读图库(获取)
      'ohos.permission.WRITE_IMAGEVIDEO',// 写图库(新增、删除、修改)
    ])
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Text('媒体文件(图库)读写授权-isAuth：' + this.isAuth)

          Button('使用Picker选择媒体库资源-无需申请权限')
            .onClick(() => {
              // 图库 Picker（无需授权），在应用内打开图库，无需跳转到图库应用
              const photoViewPicker = new photoAccessHelper.PhotoViewPicker()
              // 另一种 图库 Picker 写法，这种写法会打开新的 图库应用，选择完毕后再返回当前应用
              // const photoViewPicker = new picker.PhotoViewPicker()
              // 调用图库选择（原生界面-简单业务场景）
              photoViewPicker.select()
                .then((photoSelectResult) => {
                  AlertDialog.show({ message: JSON.stringify(photoSelectResult, null, 2) })
                })
            })

          Button('获取图库资源')
            .onClick(async () => {
              // 1. 获取图库管理器
              const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
              // 2. 准备谓词（查找条件） predicates 是一个类，需要 new 创建类实例
              const predicates = new dataSharePredicates.DataSharePredicates()
              // 3. 获取图库资源核心 API： getAssets
              // 注意： 调用 getAssets 前，需提前申请 IMAGEVIDEO 的权限，否者调用失败
              const fetchResult = await phAccessHelper.getAssets({
                fetchColumns: [], // 必传参数：查询列
                predicates: predicates  // 必传参数：谓词（查找条件）
              })
              // 获取图片数量
              this.photoCount = fetchResult.getCount()
              // 获取第一张图片资源对象
              const photoAsset = await fetchResult.getFirstObject()
              // 提取图片属性
              this.photoAssetUri = photoAsset.uri // 图片 uri (路径)
              this.photoAssetDisplayName = photoAsset.displayName // 图片名称
            })
          Text('总图片数量：' + this.photoCount)
          Text('第一张图片名称：' + this.photoAssetDisplayName)
          Image(this.photoAssetUri)
            .height(200)
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('Media Library Kit（媒体文件(图库)管理服务）')
    .titleMode(NavigationTitleMode.Mini)
  }
}