import { NavigationTitleBuilder } from '../../common/builders';
import { SENSOR_NAME_LIST, SensorName } from '../../common/constants';
import { themeManager } from '../../manager';
import { deviceInfo } from '@kit.BasicServicesKit';
import { process } from '@kit.ArkTS';
// 导入 dayjs 核心包
import dayjs from 'dayjs';
// 导入 dayjs 插件(相对时间-运行时间)
import duration from 'dayjs/plugin/duration';

// 注册 dayjs 插件(相对时间-运行时间)
dayjs.extend(duration)

@Entry
@Component
struct HardwareIndexPage {
  // 产品名称
  @State marketName: string = '-'
  // 系统版本
  @State osFullName: string = '-'
  // 系统软件API版本
  @State sdkApiVersion: string = '-'
  // 设备类型
  @State deviceType: string = '-'
  // 获取当前系统已运行的秒数
  @State uptime: number = 0
  // 网络类型
  @State netBearType: string = '-'
  // IP 地址
  @State IPAddress: string = '0.0.0.0'
  // 子网掩码
  @State subnetMask: string = '0.0.0.0'
  // 广播地址
  @State broadcastAddress: string = '0.0.0.0'
  // 屏幕分辨率（像素）
  @State displayHeight: number = 0
  @State displayWidth: number = 0
  // 屏幕刷新率（Hz）
  @State displayRefreshRate: number = 0
  // 像素密度（PPI）
  @State displayDensityDPI: number = 0
  // 支持的传感器id列表
  @State supportSensorIds: number[] = []

  onPageShow() {
    themeManager.settingStatusBarWhite()
  }

  onPageHide() {
    themeManager.settingStatusBarBlack()
  }

  aboutToAppear(): void {
    // 获取设备信息
    this.getDeviceInfo()
    // 获取进程相关信息
    this.getProcessInfo()
  }

  // 获取设备信息
  getDeviceInfo() {
    // 产品名称，可用于区分 模拟器(emulator)、真机(产品型号)
    this.marketName = deviceInfo.marketName
    // 系统版本
    this.osFullName = deviceInfo.osFullName
    // 系统软件API版本(API 9、11、12 等)
    this.sdkApiVersion = deviceInfo.sdkApiVersion.toString()
    // 设备类型，可用于区分 手机、平板、PC、车机、手表、电视 等
    this.deviceType = deviceInfo.deviceType
  }

  // 获取进程相关的信息
  getProcessInfo() {
    // 获取当前系统已运行的秒数(用于计算启动时间，运行时长)
    this.uptime = process.uptime()
  }

  // 计算上次启动时间，YYYY-MM-DD HH:mm:ss
  formatToDateTime(seconds: number) {
    // 减去秒数，返回 dayjs 对象
    const dayjsInstance = dayjs()
      .subtract(seconds, 'seconds')
    // 格式化 dayjs 对象
    return dayjsInstance.format('YYYY-MM-DD HH:mm:ss')
    // format 格式化占位符
    // 年 year     YYYY
    // 月 mouth    MM
    // 日 day      DD
    // 时 hour     hh 12小时 / HH 24小时
    // 分 minute   mm
    // 秒 second   ss
  }

  // 计算运行时间：D天HH小时mm分
  formatToDate(seconds: number) {
    // 依赖 duration 插件，duration 函数才能正常运行
    dayjs.extend(duration)
    // 根据秒数计算运行时长，返回 dayjs 对象
    const dayjsInstance = dayjs.duration(seconds, 'seconds')
    // 格式化 dayjs 对象
    return dayjsInstance.format('D天H小时mm分')
  }

  @Builder
  ListTitle(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(500)
      .fontColor($r('app.color.font'))
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: 20,
        bottom: 10
      })
      .backgroundColor($r('app.color.white'))
  }

  build() {
    Navigation() {
      // 顶部硬件信息
      Column({ space: 20 }) {
        Text(this.marketName)
          .fontSize(16)
          .fontColor($r('app.color.white'))
        Column({ space: 10 }) {
          Text('系统版本：' + this.osFullName)
            .fontSize(12)
            .fontColor($r('app.color.white'))
          Text('API 版本：' + this.sdkApiVersion)
            .fontSize(12)
            .fontColor($r('app.color.white'))
          Text('设备类型：' + this.deviceType)
            .fontSize(12)
            .fontColor($r('app.color.white'))
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: 30,
        bottom: 30
      })
      .alignItems(HorizontalAlign.Start)

      // 其他内容
      Column() {
        List() {
          ListItemGroup({ header: this.ListTitle('基本信息') }) {
            ListRow({ title: '上次启动', value: this.formatToDateTime(this.uptime) })
            ListRow({ title: '运行时间', value: this.formatToDate(this.uptime) })
          }

          ListItemGroup({ header: this.ListTitle('网络信息') }) {
            ListRow({ title: '网络类型', value: this.netBearType })
            ListRow({ title: 'IP地址', value: this.IPAddress })
            ListRow({ title: '子网掩码', value: this.subnetMask })
            ListRow({ title: '广播地址', value: this.broadcastAddress })
          }

          ListItemGroup({ header: this.ListTitle('硬件特性') }) {
            // 屏幕信息
            ListRow({ title: '屏幕分辨率（像素）', value: `${this.displayHeight}x${this.displayWidth}` })
            ListRow({ title: '屏幕刷新率（Hz）', value: this.displayRefreshRate })
            ListRow({ title: '像素密度（PPI）', value: this.displayDensityDPI })
            // 传感器信息
            ForEach(SENSOR_NAME_LIST, (item: SensorName) => {
              ListRow({
                title: item.sensorName,
                value: this.supportSensorIds.includes(item.sensorId) ? '有' : '-'
              })
            })
          }
        }
        .divider({ strokeWidth: 10 })
        .sticky(StickyStyle.Header)
        .height('100%')
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.white'))
      .borderRadius({ topLeft: 12, topRight: 12 })
      .clip(true)
    }
    .title(NavigationTitleBuilder('硬件信息'))
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .linearGradient({
      angle: 180,
      colors: [[$r('app.color.brand'), 0], [$r('app.color.brand_light'), 0.4], [$r('app.color.white'), 0.4]]
    })
  }
}

@Component
struct ListRow {
  @Prop title: string = ''
  @Prop value: string | number = ''

  build() {
    Row() {
      Text(this.title)
        .fontSize(14)
        .fontColor($r('app.color.font'))
      Text(this.value.toString())
        .fontSize(12)
        .fontColor($r('app.color.font_sub'))
    }
    .padding({ left: 20, right: 20 })
    .height(40)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

