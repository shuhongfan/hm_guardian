import { permissionManager } from '../../manager'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { picker } from '@kit.CoreFileKit'
import { dataSharePredicates } from '@kit.ArkData'
import { formatByteLength } from '../../common/utils'
import dayjs from 'dayjs'
import { promptAction } from '@kit.ArkUI'

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
  // 相册封面
  @State albumCoverUri: string = ''
  // 相册名称
  @State albumName: string = ''
  // 相册数量
  @State albumCount: string = ''

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

              // 注意事项：若忘记在 fetchColumns 添加查询字段，get 获取时会报错，比较容易踩坑
              // 获取图片文件大小
              //  1. 在 fetchColumns 添加 SIZE 字段
              //  2. 通过 get 获取文件大小
              const size = photoAsset.get(photoAccessHelper.PhotoKeys.SIZE) as number
              // 格式化后展示图片文件大小
              this.photoAssetSize = formatByteLength(size)

              // 获取图片添加日期
              //  1. 在 fetchColumns 添加 DATE_ADDED 字段
              //  2. 通过 get 获取图片添加日期（添加文件时间距1970年1月1日的秒数值）
              const dateAdded = photoAsset.get(photoAccessHelper.PhotoKeys.DATE_ADDED) as number

              // 注意事项：ArkTS 中时间戳时毫秒值，图片添加时间为秒数值，单位存在差异，需要秒数值乘 1000 后，再 dayjs 格式化
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
            .height(100)

          Button('删除第一张图片')
            .onClick(async () => {
              // 1. 建立检索条件，用于获取图片资源。
              const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
              const predicates = new dataSharePredicates.DataSharePredicates()
              // 2. 调用 PhotoAccessHelper.getAssets 接口获取目标图片资源。
              const fetchResult = await phAccessHelper.getAssets({
                fetchColumns: [],
                // predicates: predicates, 如果对象的 key 和 value 同名，可省略 :value
                predicates,
              })
              // 3. 调用 FetchResult.getFirstObject 接口获取第一张图片，即要放入回收站的图片对象。
              const photoAsset = await fetchResult.getFirstObject()
              // 4. 调用 MediaAssetChangeRequest.deleteAssets 接口将文件放入回收站(删除)。
              await photoAccessHelper.MediaAssetChangeRequest.deleteAssets(getContext(), [photoAsset])
              promptAction.showToast({ message: '删除成功' })
            })

          Button('获取用户相册')
            .onClick(async () => {
              // 1. 建立检索条件，用于获取用户相册。
              const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
              const predicates = new dataSharePredicates.DataSharePredicates()
              // 2. 调用 PhotoAccessHelper.getAlbums 接口获取用户相册资源。
              const fetchResult = await phAccessHelper.getAlbums(
                photoAccessHelper.AlbumType.USER, // 相册类型(用户相册，系统相册)
                photoAccessHelper.AlbumSubtype.USER_GENERIC, // 相册子类型（用户相册，收藏夹、视频相册）
                { fetchColumns: [], predicates }   // 可选参数
              )
              // 3. 调用 FetchResult.getFirstObject 接口获取第一个用户相册。
              const album = await fetchResult.getFirstObject()
              // 提取 用户相册封面、相册名称、相册图片数量
              this.albumCoverUri = album.coverUri
              this.albumName = album.albumName
              this.albumCount = album.count.toString()
            })
          Image(this.albumCoverUri)
            .width(100)
            .height(100)
          Text('相册名称：' + this.albumName)
          Text('相册内资源数量：' + this.albumCount)
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