import { sensor } from '@kit.SensorServiceKit'

@Entry
@Component
struct SensorTestPage {

  @State response: sensor.AccelerometerResponse | null = null

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {

          Button('获取传感器列表')
            .onClick(async () => {
              const list = await sensor.getSensorList()
              AlertDialog.show({ message: JSON.stringify(list, null, 2) })
            })

          Button('订阅加速度传感器(摇一摇)')
            .onClick(() => {
              // ACCELEROMETER 加速度（模拟器也支持测试）
              sensor.on(sensor.SensorId.ACCELEROMETER, (response) => {
                this.response = response
              })
            })

          Button('取消订阅')
            .onClick(() => {
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