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
              geoLocationManager.on(
                'locationChange', // location 位置 Change 变化
                {
                  priority: geoLocationManager.LocationRequestPriority.ACCURACY, // 根据精度选择，高精度(卫星定位，高功耗)
                  // scenario: geoLocationManager.LocationRequestScenario.NAVIGATION, // 根据场景选择，导航场景(卫星定位，高功耗)
                  timeInterval: 3, // 上报间隔，单位: 秒，默认值为 1
                },
                (location) => {
                  // 保存位置信息
                  this.location = location
                })
            })

          Button('关闭位置变化订阅')
            .onClick(() => {
              // 关闭位置变化订阅(释放资源)
              geoLocationManager.off('locationChange')
            })

          Button('判断地理编码与逆地理编码服务是否可用')
            .onClick(() => {
              const isAvailable = geoLocationManager.isGeocoderAvailable()
              AlertDialog.show({ message: '是否支持：' + isAvailable })
            })

          Button('逆地理编码(逆解析)-坐标转位置')
            .onClick(async () => {
              const addresses = await geoLocationManager.getAddressesFromLocation({
                locale: 'zh',
                latitude: 23.125178,
                longitude: 113.280637,
                maxItems: 1
              })
              AlertDialog.show({ message: JSON.stringify(addresses, null, 2) })
            })

          Button('地理编码-位置转坐标')
            .onClick(async () => {
              const location = await geoLocationManager.getAddressesFromLocationName({
                description: '北京市昌平区传智教育黑马程序员',
                maxItems: 1
              })
              AlertDialog.show({ message: JSON.stringify(location, null, 2) })
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