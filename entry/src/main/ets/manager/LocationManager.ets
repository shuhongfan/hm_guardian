import { Permissions } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';

import { promptAction } from '@kit.ArkUI';
import { permissionManager } from '.';

class LocationManager {
  // 权限配置
  private permissions: Permissions[] = [
    'ohos.permission.APPROXIMATELY_LOCATION',
    'ohos.permission.LOCATION',
  ]

  // 申请权限
  async requestPermissions() {
    try {
      // 申请权限
      await permissionManager.requestPermissions(this.permissions)
    } catch {
      promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: '定位功能需要获取权限，请在系统设置中打开定位开关',
        buttons: [
          { text: '取消', color: $r('app.color.font_sub') },
          { text: '立即开启', color: $r('app.color.brand') }
        ]
      })
        .then((res) => {
          // 打开设置页
          if (res.index === 1) {
            permissionManager.openPermissionSettingsPage()
          }
        })
    }
  }

  // 获取当前位置
  async getCurrentAddress() {
    // 获取经纬度
    const location = await geoLocationManager.getCurrentLocation()
    // 根据经纬度，调用逆地理编码服务，将坐标转换为地理描述
    // Windows 模拟器目前不支持调用 逆地理编码服务
    const addresses = await geoLocationManager.getAddressesFromLocation({
      locale: 'zh', // 语言
      latitude: location.latitude, // 纬度
      longitude: location.longitude, // 经度
      maxItems: 1  // 数量
    })
    return addresses
  }
}

export const locationManager = new LocationManager()