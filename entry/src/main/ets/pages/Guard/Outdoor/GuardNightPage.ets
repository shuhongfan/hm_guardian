import { Permissions } from '@kit.AbilityKit'
import { promptAction, router } from '@kit.ArkUI'
import { AsyncCallback } from '@kit.BasicServicesKit'
import { map, mapCommon, MapComponent } from '@kit.MapKit'
import { webSocket } from '@kit.NetworkKit'
import { locationManager, themeManager } from '../../../manager'
import { call } from '@kit.TelephonyKit'
import { getEmergencyContactAPI, postShareCreate, ShareType } from '../../../api'
import { isEmulator } from '../../../common/dev'
import { geoLocationManager } from '@kit.LocationKit'

// 夜路守护
@Entry
@Component
struct GuardNightPage {
  @StorageLink('topHeight') topHeight: number = 0
  @StorageLink('bottomHeight') bottomHeight: number = 0
  @State isShowMap: boolean = false
  // 定位地址(通过定位 + 逆地理编码得到)
  @State placeName: string = ''
  @State emergencyPhone: string = ''
  private permissions: Permissions[] = [
    'ohos.permission.APPROXIMATELY_LOCATION',
    'ohos.permission.LOCATION'
  ];
  // 华为地图
  private mapOption?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  // 分享
  private ws?: webSocket.WebSocket
  private wsReady: boolean = false;

  onPageShow() {
    // 开启沉浸式
    themeManager.enableFullScreen()
  }

  onPageHide() {
    // 关闭沉浸式
    themeManager.disableFullScreen()
  }

  // 拨打电话
  markCall(phoneNumber: string) {
    // 查询当前设备是否具有语音功能，手机/平板/桌面系统PC，不是所有设备能拨打电话
    if (call.hasVoiceCapability() === true) {
      // 三方应用只能：转到拨号屏幕，显示被叫号码
      call.makeCall(phoneNumber)
    } else {
      promptAction.showToast({ message: '当前设备不支持拨号' })
    }
    // 模拟器 BUG：模拟器不支持语音通话功能，但是 hasVoiceCapability 能力查询结果为 true
    if (isEmulator() === true) {
      promptAction.showToast({ message: '模拟跳转拨号界面：' + phoneNumber })
    }
  }

  // 页面加载
  async aboutToAppear() {
    // 获取并回显紧急联系人
    this.getDetail()
    // 申请权限
    await locationManager.requestPermissions()
    // 订阅位置变化（实时定位）
    this.onLocationChange()
    // 地图初始化
    this.initMap()
    // 初始化 WebSocket
    this.initWebSocket()
  }

  // 页面卸载
  aboutToDisappear() {
    // 关闭位置变化订阅，释放资源
    this.offLocationChange()
    // 断开 WebSocket 连接
    this.closeWebSocket()
  }

  // 获取紧急联系人详情
  async getDetail() {
    // 获取紧急联系人信息（用真机测试需 联网 ）
    const res = await getEmergencyContactAPI()
    if (res.data.result) {
      // 存储紧急联系人电话
      this.emergencyPhone = res.data.result.phone
    }
  }

  // -------------- 位置服务 --------------
  // 开启订阅位置信息(实时定位)
  onLocationChange() {
    // 订阅位置变化
    geoLocationManager.on('locationChange',
      {
        scenario: geoLocationManager.LocationRequestScenario.NAVIGATION, // 导航场景，卫星定位，高精度
        interval: 3, // 上报时间间隔，单位：秒
      },
      async (location) => {
        // 通过 ws 共享行程，把位置信息以文本方式上传服务器
        this.ws?.send(JSON.stringify(location))
        // 把地图相机移动到定位点
        this.moveMapCameraToLocation()

        // 逆地理编码，把坐标转成地址
        const addresses = await geoLocationManager.getAddressesFromLocation({
          locale: 'zh',
          latitude: location.latitude,
          longitude: location.longitude,
          maxItems: 1
        })
        // 展示地址信息
        if (addresses.length > 0) {
          this.placeName = addresses[0]?.placeName || ''
        }
      }
    )
  }

  // 关闭订阅
  offLocationChange() {
    geoLocationManager.off('locationChange')
  }

  // -------------- 位置服务 --------------


  // -------------- ↓ 地图服务 ↓ --------------
  // 初始化地图
  initMap() {
    this.isShowMap = true
    // 地图初始化参数，设置地图中心点坐标及层级
    this.mapOption = {
      // 地图相机位置
      position: {
        // 中心点
        target: {
          latitude: 31.231706,
          longitude: 121.472644
        },
        // 缩放级别
        zoom: 18
      },
      // 比例尺
      scaleControlsEnabled: true,
    };

    // 地图初始化的回调
    this.callback = async (err, mapController) => {
      if (!err) {
        // 获取地图的控制器类，用来操作地图（操作地图核心控制器，可用于注册地图回调，事件，在地图上绘制东西，相机移动等）
        this.mapController = mapController;
        // 地图加载完毕
        this.mapController.on("mapLoad", async () => {

          // 真正有功能的定位按钮
          this.mapController?.setMyLocationEnabled(true)
          this.mapController?.setMyLocationControlsEnabled(true)

          // 地图初始化时，移动相机到定位点
          this.moveMapCameraToLocation()
        });
      }
    };
  }

  // 地图初始化时，移动相机到定位点
  async moveMapCameraToLocation() {
    // 获取我的位置 (获取 WGS84/GPS 卫星坐标系)
    const location = await geoLocationManager.getCurrentLocation()
    // 转换成国内坐标系
    // 温馨提示：在国内站点，中国大陆、中国香港和中国澳门使用GCJ02坐标系，中国台湾和海外使用WGS84坐标系。
    const gcjLocation = await map.convertCoordinate(
      mapCommon.CoordinateType.WGS84, // GPS 坐标系
      mapCommon.CoordinateType.GCJ02, // GCJ 国内坐标系(国测局)
      location
    )

    //----- ↓ 地图相机 ↓ -----
    // 创建CameraUpdate对象
    const cameraUpdate = map.newCameraPosition({
      target: {
        // 华为地图的坐标系用的时 GCJ02（国测局坐标系）
        latitude: gcjLocation.latitude,
        longitude: gcjLocation.longitude
      },
      zoom: 18,
    });
    // 以动画方式移动地图相机
    this.mapController?.animateCamera(cameraUpdate);
    //----- ↑ 地图相机 ↑ -----
  }

  // -------------- ↑ 地图服务 ↑ --------------

  // -------------- ↓ WebSocket 服务 ↓ --------------
  async initWebSocket() {
    // 创建共享
    const res = await postShareCreate(ShareType.LOCATION)
    const shareId = res.data.result.shareId
    // 1. 创建 ws 对象
    this.ws = webSocket.createWebSocket()
    // 2. 与服务器建立双向连接
    this.ws.connect(`wss://guardian-api.itheima.net/share?shareType=1&shareId=${shareId}&userType=sender`)
    // 3.
    this.ws.on('open', (err) => {
      promptAction.showToast({ message: err ? '连接失败' : '当前行程已共享' + shareId })
    })
  }

  async closeWebSocket() {
    await this.ws?.close()
    promptAction.showToast({ message: '行程共享结束' })
  }

  // -------------- ↑ WebSocket 服务 ↑ --------------

  build() {
    Column() {
      Column() {
        if (this.isShowMap) {
          MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback })
            .width('100%')
            .height('100%')
        }
      }
      .layoutWeight(1)

      Column() {
        Row() {
          Row() {
            Text('“深夜人少时，尽量不要和陌生男子共乘同一步电梯”')
              .fontSize(14)
              .fontWeight(500)
              .lineHeight(20)
              .fontColor('#AEAEE6')
              .layoutWeight(1)
              .margin({ top: 25 })
            Image('/common/images/GuardIndoorPage_bozai.png')
              .height(120)
              .width(103)
              .margin({ right: 30 })
          }
          .padding({ left: 20, right: 20 })
          .margin({ top: -30 })
        }
        .width('100%')
        .height(80)
        .backgroundColor('#30307A')

        Column() {
          // 定位文本
          Row() {
            Stack() {
              Row()
                .backgroundColor('#FF4F4F')
                .width(15)
                .height(15)
                .borderRadius(15 / 2)
              Row()
                .backgroundColor('#29FF4F4F')
                .width(15)
                .height(15)
                .borderRadius(15 / 2)
                .scale({ x: 36 / 15, y: 36 / 15 })
            }
            .width(68)

            Column() {
              Text(this.placeName)
                .fontSize(14)
                .fontWeight(500)
                .fontColor('#fff')
                .width('100%')
                .textOverflow({
                  overflow: TextOverflow.Ellipsis
                })
                .maxLines(2)
              Text('您的当前位置正在向紧急恋人实时分享中')
                .fontSize(12)
                .fontColor('#AEAEE6')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .padding({ right: 15 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .height(76)
          .borderRadius(8)
          .backgroundColor('#1affffff')
          .margin({ top: 20 })

          // 夜路防护工具
          Column({ space: 20 }) {
            Row() {
              Image($r('app.media.ic_arrow_right_small'))
                .height(20)
              Text('夜路防护工具')
                .fontSize(16)
                .fontWeight(500)
                .fontColor('#fff')
            }

            Row() {
              ToolButton({ icon: $r('app.media.ic_guard_tool_sdt'), text: '手电筒' })
                .onClick(() => {
                  // TODO：切换手电筒
                })
              ToolButton({ icon: $r('app.media.ic_guard_tool_dyljb'), text: '大音量警报' })
                .onClick(() => {
                  router.pushUrl({ url: 'pages/Guard/Alarm/GuardAlarmPage' })
                })
              ToolButton({ icon: $r('app.media.ic_guard_tool_wzld'), text: '伪装来电' })
                .onClick(() => {
                  router.pushUrl({ url: 'pages/Guard/Fake/FakeTelPage' })
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
          }
          .margin({ top: 20 })
          .alignItems(HorizontalAlign.Start)

          Column({ space: 20 }) {
            // 标题
            Row() {
              Image($r('app.media.ic_arrow_right_small'))
                .height(20)
              Text('突发情况，快速求助')
                .fontSize(16)
                .fontWeight(500)
                .fontColor('#fff')
            }
            .width('100%')

            GridRow({ gutter: 10, columns: 3 }) {
              GridCol() {
                HelpButton({ icon: $r('app.media.ic_guard_help_hjjjlxr'), text: '呼叫紧急联系人' })
                  .onClick(() => {
                    // TODO：呼叫紧急联系人
                    this.markCall(this.emergencyPhone)
                  })
              }

              GridCol() {
                HelpButton({ icon: $r('app.media.ic_guard_help_fjpcs'), text: '查看附件派出所' })
                  .onClick(() => {
                    router.pushUrl({ url: 'pages/Guard/Outdoor/GuardPolicePage' })
                  })
              }

              GridCol() {
                HelpButton({ icon: $r('app.media.ic_guard_help_110bj'), text: '110报警' })
                  .onClick(() => {
                    // TODO：拨打报警电话
                    this.markCall('10010')
                  })
              }
            }
          }
          .margin({ top: 20 })
          .alignItems(HorizontalAlign.Start)
        }
        .padding({ left: 20, right: 20, bottom: 30 })

        Column() {
          Button('结束守护')
            .type(ButtonType.Normal)
            .width('100%')
            .borderRadius(10)
            .backgroundColor(Color.Transparent)
            .linearGradient({
              angle: 150,
              colors: [['#FE956F', 0], ['#FFB772', 1]]
            })
            .onClick(() => {
              router.back()
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .backgroundColor('#2F314F')
        .borderRadius({ topLeft: 12, topRight: 12 })
        .padding({
          top: 20,
          left: 20,
          right: 20,
          bottom: 20 + this.bottomHeight
        })
      }
      .linearGradient({
        angle: 180,
        colors: [['#34398C', 0], ['#4E4492', 0.5], ['#8A76BB', 1]]
      })
      .width('100%')
      .borderRadius({
        topLeft: 12,
        topRight: 12,
        bottomLeft: 0,
        bottomRight: 0
      })
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct ToolButton {
  @Prop icon: ResourceStr
  @Prop text: string

  build() {
    Column() {
      Image(this.icon)
        .width(42)
        .aspectRatio(1)
      Text(this.text)
        .fontSize(12)
        .fontWeight(500)
        .fontColor('#fff')
        .margin({ top: 10 })
    }
  }
}

@Component
struct HelpButton {
  @Prop icon: ResourceStr
  @Prop text: string

  build() {
    Column({ space: 5 }) {
      Image(this.icon)
        .width(26)
        .aspectRatio(1)
      Text(this.text)
        .fontSize(12)
        .fontColor('#fff')
    }
    .backgroundColor('#1affffff')
    .borderRadius(8)
    .height(72)
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}