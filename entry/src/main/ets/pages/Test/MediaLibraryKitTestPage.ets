import { permissionManager } from '../../manager'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { picker } from '@kit.CoreFileKit'
import { dataSharePredicates } from '@kit.ArkData'
import { formatByteLength } from '../../common/utils'
import dayjs from 'dayjs'

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
  // 图片文件大小
  @State photoAssetSize: string = ''
  // 图片添加日期
  @State photoAssetDateAdded: string = ''

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
              // predicates.orderByAsc()   // 正序：按字段从小到大
              predicates.orderByDesc(photoAccessHelper.PhotoKeys.DATE_ADDED) // 倒序：按字段从大到小
              // 3. 获取图库资源核心 API： getAssets
              // 注意： 调用 getAssets 前，需提前申请 IMAGEVIDEO 的权限，否者调用失败
              const fetchResult = await phAccessHelper.getAssets({
                fetchColumns: [photoAccessHelper.PhotoKeys.SIZE, photoAccessHelper.PhotoKeys.DATE_ADDED], // 必传参数：查询列
                predicates: predicates  // 必传参数：谓词（查找条件）
              })
              // ---------------- 获取到图片资源后续操作 ----------------
              // 获取图片数量
              this.photoCount = fetchResult.getCount()
              // 获取第一张图片资源对象（默认按图片创建时间排序）
              const photoAsset = await fetchResult.getFirstObject()
              // 提取图片属性
              this.photoAssetUri = photoAsset.uri // 图片 uri (路径)
              this.photoAssetDisplayName = photoAsset.displayName // 图片名称

              // 获取图片文件大小
              // 注意事项：若忘记在 fetchColumns 添加查询字段，get 获取时会报错，比较容易踩坑
              const size = photoAsset.get(photoAccessHelper.PhotoKeys.SIZE) as number
              // 格式化后展示图片文件大小
              this.photoAssetSize = formatByteLength(size)

              // 获取图片添加日期（添加文件时间距1970年1月1日的秒数值）
              // 注意事项：ArkTS 中时间戳时毫秒值，秒数值 需要乘 1000 后再用于 dayjs 格式化
              const dateAdded = photoAsset.get(photoAccessHelper.PhotoKeys.DATE_ADDED) as number

              this.photoAssetDateAdded = dayjs(dateAdded * 1000)
                .format('YYYY-MM-DD HH:mm:ss')
              // AlertDialog.show({
              //   message: JSON.stringify({
              //     dateAdded: dateAdded,
              //     timeStamp: Date.now()
              //   }, null, 2)
              // })
            })
          Text('总图片数量：' + this.photoCount)
          Text('第一张图片名称：' + this.photoAssetDisplayName)
          Text('第一张图片文件大小：' + this.photoAssetSize)
          Text('第一张图片添加时间：' + this.photoAssetDateAdded)
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