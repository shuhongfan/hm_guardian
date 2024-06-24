import { sensor } from '@kit.SensorServiceKit'

@Entry
@Component
struct SensorTestPage {
  // 传感器数据
  @State response: sensor.AccelerometerResponse | null = null

  aboutToDisappear() {
    // 页面销毁时，取消订阅，释放资源
    sensor.off(sensor.SensorId.ACCELEROMETER)
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {

          Button('获取传感器列表')
            .onClick(async () => {
              // 获取设备上的所有传感器信息(传感器名称、供应商、功耗、硬件版本、最小/最大采样周期 等)
              const list = await sensor.getSensorList()
              AlertDialog.show({ message: JSON.stringify(list, null, 2) })
            })

          Button('订阅加速度传感器(摇一摇)')
            .onClick(() => {
              // ACCELEROMETER 加速度（模拟器支持测试加速度传感器-摇一摇）
              sensor.on(sensor.SensorId.ACCELEROMETER, (response) => {
                this.response = response
              }, { interval: 'normal' })
              // interval  采样频率  单位：纳秒  1000000000纳秒 = 1秒， game(0.02s) > ui(0.06s) > normal(0.2s)
            })

          Button('取消订阅')
            .onClick(() => {
              // 取消订阅，页面销毁时，释放资源
              sensor.off(sensor.SensorId.ACCELEROMETER)
            })

          Text(JSON.stringify(this.response, null, 2))
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('@ohos.sensor (传感器)')
    .titleMode(NavigationTitleMode.Mini)
  }
}