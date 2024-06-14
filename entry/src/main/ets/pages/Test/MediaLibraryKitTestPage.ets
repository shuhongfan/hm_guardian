import { permissionManager } from '../../manager'

@Entry
@Component
struct MediaLibraryKitTestPage {
  // 媒体文件(图库) 是否授权
  @State isAuth: boolean = false

  aboutToAppear() {
    // 申请权限
    this.requestPermission()
  }

  // 申请权限
  async requestPermission() {
    // 申请图库权限
    this.isAuth = await permissionManager.requestPermissions([
      'ohos.permission.READ_IMAGEVIDEO', // 读图库(获取)
      'ohos.permission.WRITE_IMAGEVIDEO',// 写图库(新增、删除、修改)
    ])
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Text('图库读写授权-isAuth：' + this.isAuth)
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('Media Library Kit（媒体文件管理服务-图库）')
    .titleMode(NavigationTitleMode.Mini)
  }
}