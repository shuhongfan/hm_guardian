import { permissionManager } from '../../manager'
import { photoAccessHelper } from '@kit.MediaLibraryKit'

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
              // 图库 Picker（无需授权）
              const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
              // 调用图库选择（原生界面-简单业务场景）
              photoViewPicker.select()
                .then((photoSelectResult) => {
                  AlertDialog.show({ message: JSON.stringify(photoSelectResult, null, 2) })
                })
            })
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