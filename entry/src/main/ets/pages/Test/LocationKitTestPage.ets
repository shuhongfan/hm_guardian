import { permissionManager } from '../../manager'

@Entry
@Component
struct LocationKitTestPage {
  @State isGrant: boolean = false

  aboutToAppear() {
    this.requestPermissions()
  }

  // 申请权限
  async requestPermissions() {
    this.isGrant = await permissionManager.requestPermissions([
      'ohos.permission.LOCATION', // 精准定位
      'ohos.permission.APPROXIMATELY_LOCATION',// 模糊定位
    ])
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Text('位置服务是否授权：' + this.isGrant)
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('Location Kit 位置服务')
    .titleMode(NavigationTitleMode.Mini)
  }
}