import { permissionManager } from '../../manager'
import { geoLocationManager } from '@kit.LocationKit'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct LocationKitTestPage {
  // 定位是否授权
  @State isGrant: boolean = false
  // 位置信息
  @State location: geoLocationManager.Location | null = null

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
          Text('当前位置信息：' + JSON.stringify(this.location, null, 2))

          Button('获取当前位置')
            .onClick(async () => {
              try {
                // 获取当前位置信息
                const location = await geoLocationManager.getCurrentLocation()
                // 保存位置信息
                this.location = location
              } catch (error) {
                promptAction.showToast({ message: '请在控制中心，开启定位服务' })
              }
            })

          // 可通过 模拟器 -> GPS -> 场景模拟 调试，模拟 跑步、骑行、驾驶 三种常见场景
          Button('开启位置变化订阅')
            .onClick(() => {
              // 开启位置变化订阅(实时定位)
              geoLocationManager.on('locationChange', {}, (location) => {
                // 保存位置信息
                this.location = location
              })
            })

          Button('关闭位置变化订阅')
            .onClick(() => {
              // 关闭位置变化订阅(释放资源)
              geoLocationManager.off('locationChange')
            })
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