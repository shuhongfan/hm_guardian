import { sensor } from '@kit.SensorServiceKit'
import { NavigationTitleBuilder } from '../../../common/builders/index'
import { themeManager } from '../../../manager/index'
import { promptAction } from '@kit.ArkUI'

// 利用磁场传感器检测电磁信号(用于排查隐秘摄像头)
@Entry
@Component
struct CheckCameraPage {
  // 传感器数据
  @State sensorResponse: sensor.MagneticFieldResponse | null = null
  // 最大环境磁场强度，单位 : μT
  @State maxData: number = 0
  @State dataList: number[] = []
  // 警报阈值
  private alarmValue: number = 100
  private scroller: Scroller = new Scroller()

  onPageShow() {
    themeManager.settingStatusBarWhite()
  }

  onPageHide() {
    themeManager.settingStatusBarBlack()
  }

  aboutToAppear() {
    this.startSensor()
  }

  aboutToDisappear() {
    this.stopSensor()
  }

  // 订阅传感器
  startSensor() {
    try {
      sensor.on(sensor.SensorId.MAGNETIC_FIELD, (response) => {
        this.sensorResponse = response
      }, { interval: 'ui' })
    } catch (error) {
      promptAction.showToast({ message: '当前设备硬件不支持' })
    }
  }

  // 取消传感器订阅
  stopSensor() {
    try {
      sensor.off(sensor.SensorId.MAGNETIC_FIELD)
    } catch { }
  }

  // 5.0.3.403 版本的 Navigation 有 BUG，不添加无法给 Navigation 设置标题和返回箭头
  pathInfos: NavPathStack = new NavPathStack()

  build() {
    // 修复 5.0.3.403 版本的 Navigation 的 BUG
    Navigation(this.pathInfos) {
      Column({ space: 20 }) {
        Text('环境磁场强度')
          .fontSize(14)
          .fontColor($r('app.color.font_sub'))
        Text(this.maxData.toFixed(2) + 'uT')
          .fontSize(30)
          .fontColor(this.maxData >= this.alarmValue ? $r('app.color.danger') : $r('app.color.brand'))
        Text(this.maxData >= this.alarmValue ? '检测到较强信号波动，请留意附近可疑位置' : '未发现异常信号')
          .fontSize(14)
          .fontColor(this.maxData >= this.alarmValue ? $r('app.color.danger') : $r('app.color.white'))
        Text('传感器数据：' + JSON.stringify(this.sensorResponse, null, 2))
          .fontColor('#fff')
      }
      .padding({ top: 50 })

      Row() {
        Scroll(this.scroller) {
          Row({ space: 4 }) {
            ForEach(this.dataList, (value: number) => {
              Column()
                .height(value > 300 ? 300 : value)
                .width(2)
                .backgroundColor(value >= this.alarmValue ? $r('app.color.danger') : $r('app.color.brand'))
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBarWidth(0)
      }
      .backgroundColor('#201F24')
      .width('100%')
      .height(370)
      .margin({ top: 20, bottom: 40 })

      Row() {
        Text('请注意区别其他电器的信号')
          .fontSize(14)
          .fontColor($r('app.color.white'))
      }
    }
    .title(NavigationTitleBuilder('摄像头检测'))
    .hideBackButton(true)
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('app.color.black'))
  }
}